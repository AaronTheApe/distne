defmodule Distne.Net.In do
  @moduledoc """
  An In acts as an input node in a Net
  """
  use GenServer

  require Record
  Record.defrecordp :state, sinks: HashSet.new

  alias Distne.Net.In, as: In
  alias Distne.Net.Stimable, as: Stimable

  @doc """
  Starts a new In process, returning its PID
  """
  def start_link() do
    GenServer.start_link(In, state())
  end

  @doc """
  Adds PID `sink` as a sink to In with PID `pid`
  """
  def add_sink(pid, sink) do
    GenServer.call(pid, {:add_sink, sink})
  end

  def handle_call({:add_sink, sink}, _from, {:state, sinks}) do
    {:reply, :ok, {:state, Set.put(sinks, sink)}}
  end

  def handle_cast({:stim, _from, amount}, {:state, sinks}) do
    Enum.each(sinks, fn(sink) ->
      Stimable.stim(sink, amount)
    end)
    {:noreply, {:state, sinks}}
  end
end
