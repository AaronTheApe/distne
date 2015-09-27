defmodule Distne.Task.BitParity.BitParityMonitorTest do
  use ExUnit.Case

  alias Distne.Task.BitParity.BitParityMonitor, as: BitParityMonitor
  alias Distne.Net.TestProbe, as: TestProbe

  test "BitParityMonitor sets up task for net and forwards fitness of net to pop" do
    settings = %{size: 2}
    {:ok, net} = TestProbe.start_link()
    {:ok, fit_mon} = TestProbe.start_link()
    {:ok, monitor} = BitParityMonitor.start_link(settings, net, fit_mon)
    {:set_actuator_array, _} = TestProbe.received(net, 100)
    {:input_vector, [_bias, _bit1, _bit2]} = TestProbe.received(net, 100)
    GenServer.cast(monitor, {:success, true})
    TestProbe.assert_receive(fit_mon, {:fitness, net, 1.0}, 100)
  end
end
