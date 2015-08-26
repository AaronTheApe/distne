defmodule Distne.Task.BitParity.BitParityTask do
  use GenServer

  require Record
  Record.defrecordp :state, bits: nil, nc: nil, monitor: nil

  alias Distne.Task.BitParity.BitParityTask, as: BitParityTask
  alias Distne.Task.BitParity.BitParity, as: BitParity

  def start_link(size, monitor) do
    bits = Enum.map(1..size, fn(_) ->
      if :rand.uniform > 0.5 do
        1
      else
        0
      end
    end)
    GenServer.start_link(BitParityTask, state(bits: bits, monitor: monitor))
  end

  def begin(task, nc) do
    GenServer.cast(task, {:begin, nc})
  end

  def parity(task, parity) do
    GenServer.cast(task, {:parity, parity})
  end

  def handle_cast({:begin, nc}, state) do
    GenServer.cast(nc, {:bits, state(state, :bits)})
    {:noreply, state(state, nc: nc)}
  end

  def handle_cast({:parity, parity}, state) do
    success =
      if parity == BitParity.even(state(state, :bits)) do
        true
      else
        false
      end
    GenServer.cast(state(state, :monitor), {:success, success})
    {:noreply, state}
  end
end
