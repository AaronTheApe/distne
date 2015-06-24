defmodule Distne.Net.Con do
  @moduledoc """
  A Con acts as a weighted connection between other Net nodes
  """
  use GenServer

  require Record
  Record.defrecordp :state, source: nil, weight: nil, sink: nil

  alias Distne.Net.Con, as: Con
  alias Distne.Net.Stimable, as: Stimable

  @doc """
  Starts a new Con with weight `weight`
  """
  def start_link(weight) do
    GenServer.start_link(Con, state(weight: weight))
  end

  @doc """
  Sets source of Con with PID `con` to PID `source`
  """
  def set_source(con, source) do
    GenServer.call(con, {:set_source, source})
  end

  @doc """
  Sets the sink of Con identified by pid
  """
  def set_sink(pid, sink) do
    GenServer.call(pid, {:set_sink, sink})
  end

  def handle_call({:set_source, source}, _from, state) do
    {:reply, :ok, state(state, source: source)}
  end

  def handle_call({:set_sink, sink}, _from, state) do
    {:reply, :ok, state(state, sink: sink)}
  end

  def handle_cast({:stim, _from, amount}, state) do
    Stimable.stim(state(state, :sink), state(state, :weight)*amount)
    {:noreply, state}
  end
end
