defmodule Distne.Method.Neat.IdGen do
  @moduledoc """
  An IdGen ensures that unique mutations receive unique identifiers, while
  non-unique mutations receive the same identifiers
  """
  use GenServer

  require Record
  Record.defrecordp :state, next_node_id: nil, next_innov_num: nil, prev_innov_nums: %{}, prev_node_ids: %{}

  alias Distne.Method.Neat.IdGen, as: IdGen

  @doc """
  Starts a new IdGen with next_node_id and next_innov_num
  """
  def start_link(next_node_id, next_innov_num) do
    GenServer.start_link(IdGen, state(next_node_id: next_node_id, next_innov_num: next_innov_num))
  end

  @doc """

  """
  def innov_num(pid, in_node_id, out_node_id) do
    GenServer.call(pid, {:innov_num, in_node_id, out_node_id})
  end

  def handle_call({:innov_num, in_node_id, out_node_id}, _from, state) do
    prev_innov_nums = state(state, :prev_innov_nums)
    next_innov_num = state(state, :next_innov_num)
    if Map.has_key?(prev_innov_nums, {in_node_id, out_node_id}) do
      {:reply, {:ok, Map.get(prev_innov_nums, {in_node_id, out_node_id})}, state}
    else
      {:reply, {:ok, next_innov_num}, state(state, next_innov_num: next_innov_num + 1, prev_innov_nums: Map.put(prev_innov_nums, {in_node_id, out_node_id}, next_innov_num)) }
    end
  end

  def handle_call({:node_id, in_node_id, out_node_id}, _from, state) do
    prev_node_ids = state(state, :prev_node_ids)
    next_node_id = state(state, :next_node_id)
    if Map.has_key?(prev_node_ids, {in_node_id, out_node_id}) do
      {:reply, {:ok, Map.get(prev_node_ids, {in_node_id, out_node_id})}, state}
    else
      {:reply, {:ok, next_node_id}, state(state, next_node_id: next_node_id + 1, prev_node_ids: Map.put(prev_node_ids, {in_node_id, out_node_id}, next_node_id))}
    end
  end

  def node_id(pid, in_node_id, out_node_id) do
    GenServer.call(pid, {:node_id,  in_node_id, out_node_id})
  end
end
