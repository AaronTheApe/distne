defmodule Distne.Net.TestProbe do
  @moduledoc """
  A TestProbe acts as sender and receiver of messages for testing purposes
  """
  use GenServer
  require Record

  Record.defrecord State, received: nil, sent: nil

  alias Distne.Net.TestProbe, as: TestProbe

  @doc """
  Starts a new TestProbe
  """
  def start_link() do
    GenServer.start_link(TestProbe, {State, nil, nil})
  end

  def handle_call(:received, _from, {State, received, sent}) do
    {:reply, {:ok, received}, {State, received, sent}}
  end

  def handle_call({:send, pid, message}, _from, {State, received, sent}) do
    GenServer.cast(pid, message)
    {:reply, :ok, {State, received, message}}
  end

  def handle_call(message, _from, {State, _, sent}) do
    {:reply, :ok, {State, message, sent}}
  end

  def handle_cast(message, {State, _, sent}) do
    {:noreply, {State, message, sent}}
  end
end
