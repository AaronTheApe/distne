defmodule DistneTest do
  use ExUnit.Case

  test "Con repeatedly forwards {:stim, amount} as {:stim, amount*weight}" do
    weight = :random.uniform()
    {:ok, pid} = Distne.Net.Con.start_link(weight)
    {:ok, sink} = Distne.Net.TestProbe.start_link()
    :ok = GenServer.call(pid, {:set_sink, sink})
    Enum.each(1..10, fn (_)  ->
      amount = :random.uniform()
      GenServer.call(pid, {:stim, amount})
      expected_sink_stim_amount = weight * amount
      assert {:ok, {:stim, expected_sink_stim_amount}} == GenServer.call(sink, :received)
    end)
  end
end

