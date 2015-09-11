defmodule Distne.Net.TestProbe do
  @moduledoc """
  A TestProbe acts as sender and receiver of messages for testing purposes
  """
  use GenServer
  require Record
  require ExUnit.Assertions

  defmodule State do
    defstruct received: nil, sent: nil
  end

  alias Distne.Net.TestProbe, as: TestProbe

  @doc """
  Starts a new TestProbe
  """
  def start_link() do
    GenServer.start_link(TestProbe, %State{})
  end

  def assert_receive(pid, expected, remaining) do
    if remaining > 0 do
      try do
        case GenServer.call(pid, :received) do
          {:ok, received} ->  ExUnit.Assertions.assert(expected = received)
          {:error, reason} -> assert_receive(pid, expected, remaining - 5000)
        end
      catch
        :exit, _ -> assert_receive(pid, expected, remaining - 5000)
      end
    else
        ExUnit.Assertions.flunk("Testprobe expected to receive: \n\n#{inspect expected}\n\n but received: \n\nnil")
    end
  end

  def received(pid, remaining) do
    if remaining > 0 do
      try do
        case GenServer.call(pid, :received) do
          {:ok, received} -> received
          {:error, reason} -> received(pid, remaining - 5000)
        end
      catch
        :exit, _ -> received(pid, remaining - 5000)
      end
    else
      nil
    end
  end

  def init(args) do
    {:ok, blocking_queue} = BlockingQueue.start_link(5)
    {:ok, %State{received: blocking_queue, sent: nil}}
  end

  def handle_call(:received, _from, state) do
    received = BlockingQueue.pop(state.received)
    {:reply, {:ok, received}, state}
  end

  def handle_call({:send, pid, message}, _from, state) do
    GenServer.cast(pid, message)
    {:reply, :ok, %State{state|sent: message}}
  end

  def handle_call(message, _from, state) do
    BlockingQueue.push(state.received, message)
    {:reply, :ok, state}
  end

  def handle_cast(message, state) do
    BlockingQueue.push(state.received, message)
    {:noreply, state}
  end
end
