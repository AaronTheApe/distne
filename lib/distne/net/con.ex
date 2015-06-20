defmodule Distne.Net.Con do
  @moduledoc """
  A Con acts as a weighted connection between other Net nodes
  """
  use GenServer

  require Record
  Record.defrecordp :state, weight: nil, sink: nil

  alias Distne.Net.Con, as: Con
  alias Distne.Net.Stimable, as: Stimable
 
  @doc """
  Starts a new Con with weight `weight`
  """
  def start_link(weight) do
    GenServer.start_link(Con, state(weight: weight))
  end

  @doc """
  Sets the sink of Con identified by pid
  """
  def set_sink(pid, sink) do
    GenServer.call(pid, {:set_sink, sink})
  end

  def handle_call({:stim, amount}, _from, {:state, weight, sink}) do
    Stimable.stim(sink, weight*amount)
    {:reply, :ok, {:state, weight, sink}}
  end

  def handle_call({:set_sink, sink}, _from, {:state, weight, _}) do
    {:reply, :ok, {:state, weight, sink}}
  end
end
