defmodule Distne.Net.TestProbe do
  use GenServer
  require Record

  Record.defrecord State, received: nil, sent: nil

  def start_link() do
    GenServer.start_link(Distne.Net.TestProbe, {State, nil, nil})
  end

  def handle_call({:stim, amount}, _from, {State, _, sent}) do
    {:reply, :ok, {State, {:stim, amount}, sent}}
  end

  def handle_call(:received, _from, {State, received, sent}) do
    {:reply, {:ok, received}, {State, received, sent}}
  end

  def handle_call({:send, pid, message}, _from, {State, received, sent}) do
    GenServer.call(pid, message)
    {:reply, :ok, {State, received, message}}
  end

  def handle_call(:sent, _from, {State, received, sent}) do
    {:reply, {:ok, sent}, {State, received, sent}}
  end
end
