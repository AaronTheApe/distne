defmodule Distne.Task.BitParity.BitParityTaskTest do
  use ExUnit.Case

  alias Distne.Task.BitParity.BitParityTask, as: BitParityTask
  alias Distne.Task.BitParity.BitParity, as: BitParity
  alias Distne.Net.TestProbe, as: TestProbe

  test "BitParityTask sends sensor_array size string of bits, receives bit from actuator_array, and sends monitor true iaoi bit is even bit parity bit for original string of bits" do
    {:ok, monitor} = TestProbe.start_link()
    size = 5
    {:ok, task} = BitParityTask.start_link(size, monitor)
    {:ok, nc} = TestProbe.start_link()
    BitParityTask.begin(task, nc)
    {:bits, bits} = TestProbe.received(nc, 100)
    assert Enum.count(bits) > 0
    perform_success =
      if :rand.uniform() > 0.5 do
        true
      else
        false
      end
    parity =
      if perform_success do
        BitParity.even(bits)
      else
        BitParity.odd(bits)
      end
    BitParityTask.parity(task, parity)
    TestProbe.assert_receive(monitor, {:success, perform_success}, 100)
  end
end
