defmodule Distne.Net.TestProbe do
  @moduledoc """
  A TestProbe acts as sender and receiver of messages for testing purposes
  """
  use GenServer
  require Record
  require ExUnit.Assertions

  Record.defrecord State, received: nil, sent: nil

  alias Distne.Net.TestProbe, as: TestProbe

  @doc """
  Starts a new TestProbe
  """
  def start_link() do
    GenServer.start_link(TestProbe, {State, nil, nil})
  end

  def assert_receive(pid, expected, remaining) do
    {:ok, received} = GenServer.call(pid, :received)
    if remaining > 0 && received != expected do
      :timer.sleep(5)
      assert_receive(pid, expected, remaining - 5)
    else
      if expected != received do
        ExUnit.Assertions.flunk("Testprobe expected to receive: #{inspect expected}, but received: #{inspect received}")
      end
    end
  end

  def handle_call(:received, _from, {State, received, sent}) do
    {:reply, {:ok, received}, {State, received, sent}}
  end

  def handle_call({:send, pid, message}, _from, {State, received, _sent}) do
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
