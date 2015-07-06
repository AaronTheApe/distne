defmodule Distne.Net.NetTest do
  use ExUnit.Case

  alias Distne.Net.Net, as: Net
  alias Distne.Net.TestProbe, as: TestProbe

  test "Net repeatedly performs layered erf calculation" do
    {:ok, net} = Net.start_link()
    {:ok, sensor_array} = TestProbe.start_link()
    :ok = Net.set_sensor_array(net, sensor_array)
    {:ok, input} = Net.add_in(net)
    {:ok, hid} = Net.add_hid(net)
    {:ok, out} = Net.add_out(net)
    {:ok, _con1} = Net.connect(net, input, hid, 0.1)
    {:ok, _con2} = Net.connect(net, hid, out, 0.2)
    {:ok, actuator_array} = TestProbe.start_link()
    :ok = Net.set_actuator_array(net, actuator_array)
    input_vector = [0.3]
    Net.input_vector(net, input_vector)
    expected_output_vector = {:output_vector, [:math.erf(0.2 * :math.erf(0.1 * 0.3))]}
    :timer.sleep(1000)
    assert {:ok, expected_output_vector} == GenServer.call(actuator_array, :received)
  end

end
