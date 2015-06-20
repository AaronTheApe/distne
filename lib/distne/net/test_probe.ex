defmodule Distne.Net.TestProbe do
  @moduledoc """
  A TestProbe acts as sender and receiver of messages for testing purposes
  """
  use GenServer
  require Record

  Record.defrecord State, received: nil, sent: nil

  @doc """
  Starts a new TestProbe
  """
  def start_link() do
    GenServer.start_link(Distne.Net.TestProbe, {State, nil, nil})
  end

  def handle_call(:received, _from, {State, received, sent}) do
    {:reply, {:ok, received}, {State, received, sent}}
  end

  def handle_call({:send, pid, message}, _from, {State, received, sent}) do
    GenServer.call(pid, message)
    {:reply, :ok, {State, received, message}}
  end

  def handle_call(message, _from, {State, _, sent}) do
    {:reply, :ok, {State, message, sent}}
  end
end
