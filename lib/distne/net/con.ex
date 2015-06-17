defmodule Distne.Net.Con do
  use GenServer

  require Record
  Record.defrecordp :state, weight: nil, sink: nil
 
  def start_link(weight) do
    GenServer.start_link(Distne.Net.Con, state(weight: weight))
  end

  def stim(pid, amount) do
    GenServer.call(pid, {:stim, amount})
  end

  def set_sink(pid, sink) do
    GenServer.call(pid, {:set_sink, sink})
  end

  def handle_call({:stim, amount}, _from, {:state, weight, sink}) do
    GenServer.call(sink, {:stim, weight*amount})
    {:reply, :ok, {:state, weight, sink}}
  end

  def handle_call({:set_sink, sink}, _from, {:state, weight, _}) do
    {:reply, :ok, {:state, weight, sink}}
  end
end
