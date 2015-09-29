defmodule Distne.Net.Out do
  @moduledoc """
  An Out acts as an output node in a Net
  """
  use GenServer

  require Record
  Record.defrecordp :state, sources: HashSet.new, sink: nil, pending: HashSet.new, sum: 0.0

  alias Distne.Net.Out, as: Out
  alias Distne.Net.Stimable, as: Stimable

  @doc """
  Starts a new Out
  """
  def start_link() do
    GenServer.start_link(Out, state())
  end

  @doc """
  Sets PID `pid` as the sink the Out with PID `pid`
  """
  def set_sink(pid, sink) do
    GenServer.call(pid, {:set_sink, sink})
  end

  @doc """
  Adds PID `source` as a source to the Out identified by `pid`
  """
  def add_source(pid, source) do
    GenServer.call(pid, {:add_source, source})
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_call({:add_source, source}, _from, {:state, sources, sink, pending, sum}) do
    {:reply, :ok, {:state, Set.put(sources, source), sink, Set.put(pending, source), sum}}
  end

  def handle_call({:set_sink, sink}, _from, {:state, sources, _, pending, sum}) do
    {:reply, :ok, {:state, sources, sink, pending, sum}}
  end

  def handle_cast({:stim, from, amount}, {:state, sources, sink, pending, sum}) do
    newSum = sum + amount
    newPending = Set.delete(pending, from)
    if Set.size(newPending) == 0 do
      activation = :math.erf(newSum)
      Stimable.stim(sink, activation)
      {:noreply, {:state, sources, sink, sources, 0.0}}
    else
      {:noreply, {:state, sources, sink, newPending, newSum}}
    end
  end
end
