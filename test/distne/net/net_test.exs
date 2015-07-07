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
    con1_weight = :random.uniform()
    con2_weight = :random.uniform()
    {:ok, _con1} = Net.connect(net, input, hid, con1_weight)
    {:ok, _con2} = Net.connect(net, hid, out, con2_weight)
    {:ok, actuator_array} = TestProbe.start_link()
    :ok = Net.set_actuator_array(net, actuator_array)
    Enum.each(1..10, fn(_time) ->
      input_vector_weight = :random.uniform()
      input_vector = [input_vector_weight]
      Net.input_vector(net, input_vector)
      expected_output_vector = {:output_vector, [:math.erf(con2_weight * :math.erf(con1_weight * input_vector_weight))]}
      :timer.sleep(1000)
      assert {:ok, expected_output_vector} == GenServer.call(actuator_array, :received)
   end)
  end

end
