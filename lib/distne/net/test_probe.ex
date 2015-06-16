defmodule Distne.Net.TestProbe do
  use GenServer
  require Record

  Record.defrecord State, received: nil

  def start_link() do
    GenServer.start_link(Distne.Net.TestProbe, {State, nil})
  end

  def handle_call({:stim, amount}, _from, {State, _}) do
    {:reply, :ok, {State, {:stim, amount}}}
  end

  def handle_call(:received, _from, {State, received}) do
    {:reply, {:ok, received}, {State, received}}
  end

end
