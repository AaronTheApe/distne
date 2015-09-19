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
    :timer.sleep(5)
    if remaining > 0 do
      try do
        case GenServer.call(pid, :received) do
          {:ok, received} -> ExUnit.Assertions.assert(expected = received)
          {:error, _reason} -> assert_receive(pid, expected, remaining - 5)
        end
      catch
        :exit, _ -> assert_receive(pid, expected, remaining - 5)
      end
    else
        ExUnit.Assertions.flunk("Testprobe expected to receive: \n\n#{inspect expected}\n\n but received: \n\nnil")
    end
  end

  def received(pid, remaining) do
    :timer.sleep(5)
    if remaining > 0 do
      try do
        case GenServer.call(pid, :received) do
          {:ok, received} -> received
          {:error, _reason} -> received(pid, remaining - 5)
        end
      catch
        :exit, _ -> received(pid, remaining - 5)
      end
    else
      nil
    end
  end

  def init(_args) do
    {:ok, %State{received: :queue.new, sent: nil}}
  end

  def handle_call(:received, _from, state) do
    case :queue.out(state.received) do
      {{:value, msg}, new_received} -> {:reply, {:ok, msg}, %State{state|received: new_received}}
      {:empty, _received} -> {:reply, {:error, "nothing received"}, state}
    end
  end

  def handle_call({:send, pid, message}, _from, state) do
    GenServer.cast(pid, message)
    {:reply, :ok, %State{state|sent: message}}
  end

  def handle_call(message, _from, state) do
    {:reply, :ok, %State{state|received: :queue.in(message, state.received)}}
  end

  def handle_cast(message, state) do
    {:noreply, %State{state|received: :queue.in(message, state.received)}}
  end
end
