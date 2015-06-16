defmodule Distne.Net.Con do
  use GenServer
  require Record

  Record.defrecord State, weight: nil, sink: nil
 
  def start_link(weight) do
    GenServer.start_link(Distne.Net.Con, {State, weight, nil})
  end

  def handle_call({:stim, amount}, _from, {State, weight, sink}) do
    GenServer.call(sink, {:stim, weight*amount})
    {:reply, :ok, {State, weight, sink}}
  end

  def handle_call({:set_sink, sink}, _from, {State, weight, _}) do
    {:reply, :ok, {State, weight, sink}}
  end
end
