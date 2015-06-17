defmodule Distne.Net.In do
  use GenServer

  require Record
  Record.defrecordp :state, sinks: HashSet.new

  def start_link() do
    GenServer.start_link(Distne.Net.In, state())
  end

  def add_sink(pid, sink) do
    GenServer.call(pid, {:add_sink, sink})
  end

  def stim(pid, amount) do
    GenServer.call(pid, {:stim, amount})
  end

  def handle_call({:add_sink, sink}, _from, {:state, sinks}) do
    {:reply, :ok, {:state, Set.put(sinks, sink)}}
  end

  def handle_call({:stim, amount}, _from, {:state, sinks}) do
    Enum.each(sinks, fn(sink) ->
      GenServer.call(sink, {:stim, amount})
    end)
    {:reply, :ok, {State, sinks}}
  end
end
