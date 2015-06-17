defmodule DistneTest do
  use ExUnit.Case

  test "Input repeatedly forwards {:stim, amount} to its sinks" do
    {:ok, pid} = Distne.Net.In.start_link()
    sinks = Enum.map(1..10, fn(_) ->
      {:ok, sink} = Distne.Net.TestProbe.start_link()
      sink
    end)
    Enum.each(sinks, fn(sink) ->
      Distne.Net.In.add_sink(pid, sink)
    end)
    amount = :random.uniform()
    Distne.Net.In.stim(pid, amount)
    Enum.each(sinks, fn(sink) ->
      assert {:ok, {:stim, amount}} == GenServer.call(sink, :received)
    end)
  end

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

