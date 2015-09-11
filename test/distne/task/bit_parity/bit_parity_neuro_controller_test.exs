defmodule Distne.Task.BitParity.BitParityNeuroControllerTest do
  use ExUnit.Case

  alias Distne.Task.BitParity.BitParityNeuroController, as: BitParityNeuroController
  alias Distne.Net.TestProbe, as: TestProbe

  test "BitParityNeuroController receives bits, and casts them as input vector(0 -> 0.1 and 1 -> 0.2) to net" do
    {:ok, net} = TestProbe.start_link()
    {:ok, task} = TestProbe.start_link()
    bits = [0,1,0,1,0]
    {:ok, nc} = BitParityNeuroController.start_link(net, task)
    BitParityNeuroController.bits(nc, bits)
    bias = 1.0
    expected_input_vector = [bias | Enum.map(bits, fn(b) ->
      if b == 0 do
        0.1
      else
        0.9
      end
    end)]
    TestProbe.assert_receive(net, {:input_vector, expected_input_vector}, 100)
  end

  test "BitParityNeuroController receives output vector, and casts them as bits(0 -> 0.1 and 1 -> 0.2) to task" do
    {:ok, net} = TestProbe.start_link()
    {:ok, task} = TestProbe.start_link()
    output = :rand.uniform()
    output_vector = [output]
    {:ok, nc} = BitParityNeuroController.start_link(net, task)
    BitParityNeuroController.output_vector(nc, output_vector)
    expected_parity =
      if output > 0.0 do
        1
      else
        0
      end
    TestProbe.assert_receive(task, {:parity, expected_parity}, 100)
  end
end
