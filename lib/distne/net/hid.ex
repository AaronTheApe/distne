defmodule Distne.Net.Hid do
  @moduledoc """
  A Hid acts as a hidden node in a Net
  """
  use GenServer

  require Record
  Record.defrecordp :state, sources: HashSet.new, sinks: HashSet.new, pending: HashSet.new, sum: 0.0

  alias Distne.Net.Hid, as: Hid
  alias Distne.Net.Stimable, as: Stimable

  @doc """
  Starts a new Hid
  """
  def start_link() do
    GenServer.start_link(Hid, state())
  end

  @doc """
  Adds sink with PID `sink` to the Hid with PID `pid`
  """
  def add_sink(pid, sink) do
    GenServer.call(pid, {:add_sink, sink})
  end

  @doc """
  Adds source with PID `source` to Hid with PID `pid`
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

  def handle_call({:add_source, source}, _from, {:state, sources, sinks, pending, sum}) do
    {:reply, :ok, {:state, Set.put(sources, source), sinks, Set.put(pending, source), sum}}
  end

  def handle_call({:add_sink, sink}, _from, {:state, sources, sinks, pending, sum}) do
    {:reply, :ok, {:state, sources, Set.put(sinks, sink), pending, sum}}
  end

  def handle_cast({:stim, from, amount}, {:state, sources, sinks, pending, sum}) do
    newSum = sum + amount
    newPending = Set.delete(pending, from)
    if Set.size(newPending) == 0 do
      activation = :math.erf(newSum)
      Enum.each(sinks, fn(sink) ->
        Stimable.stim(sink, activation)
      end)
      {:noreply, {:state, sources, sinks, sources, 0.0}}
    else
      {:noreply, {:state, sources, sinks, newPending, newSum}}
    end
  end
end
