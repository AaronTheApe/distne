defmodule Distne.Net.Out do
  @moduledoc """
  An Out acts as an output node in a Net
  """
  use GenServer

  require Record
  Record.defrecordp :state, sources: HashSet.new, sink: nil, pending: HashSet.new, sum: 0.0

  @doc """
  Starts a new Out
  """
  def start_link() do
    GenServer.start_link(Distne.Net.Out, state())
  end

  @doc """
  Sets the sink of the Out identified by pid
  """
  def set_sink(pid, sink) do
    GenServer.call(pid, {:set_sink, sink})
  end

  @doc """
  Adds source to Out identified by pid
  """
  def add_source(pid, source) do
    GenServer.call(pid, {:add_source, source})
  end

  def handle_call({:add_source, source}, _from, {:state, sources, sink, pending, sum}) do
    {:reply, :ok, {:state, Set.put(sources, source), sink, Set.put(pending, source), sum}}
  end

  def handle_call({:set_sink, sink}, _from, {:state, sources, _, pending, sum}) do
    {:reply, :ok, {:state, sources, sink, pending, sum}}
  end

  def handle_call({:stim, amount}, {from, _}, {:state, sources, sink, pending, sum}) do
    newSum = sum + amount
    newPending = Set.delete(pending, from)
    if Set.size(newPending) == 0 do
      activation = :math.erf(newSum)
      Distne.Net.Stimable.stim(sink, activation)
      {:reply, :ok, {:state, sources, sink, sources, 0.0}}
    else
      {:reply, :ok, {:state, sources, sink, newPending, newSum}}
    end
  end
end