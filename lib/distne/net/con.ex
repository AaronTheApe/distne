defmodule Distne.Net.Con do
  use GenServer

  require Record
  Record.defrecord :state, weight: nil, sink: nil
 
  def start_link(weight) do
    GenServer.start_link(Distne.Net.Con, state(weight: weight))
  end

  def handle_call({:stim, amount}, _from, {:state, weight, sink}) do
    GenServer.call(sink, {:stim, weight*amount})
    {:reply, :ok, {:state, weight, sink}}
  end

  def handle_call({:set_sink, sink}, _from, {:state, weight, _}) do
    {:reply, :ok, {:state, weight, sink}}
  end
end
