defmodule Distne.Net.In do
  @moduledoc """
  An In acts as an artificial neural network input node
  """
  use GenServer

  require Record
  Record.defrecordp :state, sinks: HashSet.new

  @doc """
  Starts a new In process, returning its PID
  """
  def start_link() do
    GenServer.start_link(Distne.Net.In, state())
  end

  @doc """
  Adds another sink node to this In -- another actor which will be forwarded all stims received by this In
  """
  def add_sink(pid, sink) do
    GenServer.call(pid, {:add_sink, sink})
  end

  def handle_call({:add_sink, sink}, _from, {:state, sinks}) do
    {:reply, :ok, {:state, Set.put(sinks, sink)}}
  end

  def handle_call({:stim, amount}, _from, {:state, sinks}) do
    Enum.each(sinks, fn(sink) ->
      Distne.Net.Stimable.stim(sink, amount) 
    end)
    {:reply, :ok, {State, sinks}}
  end
end
