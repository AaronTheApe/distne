defmodule DistneTest do
  use ExUnit.Case

  test "hid repeatedly erfs the sum of all source {:stim, amount}s" do
    {:ok, pid} = Distne.Net.Hid.start_link()
    sinks = Enum.map(1..10, fn(_) ->
      {:ok, sink} = Distne.Net.TestProbe.start_link()
      sink
    end)
    Enum.each(sinks, fn(sink) ->
      Distne.Net.Hid.add_sink(pid, sink)
    end)
    sources = Enum.map(1..10, fn(_) ->
      {:ok, source} = Distne.Net.TestProbe.start_link()
      source
    end)
    Enum.each(sources, fn(source) ->
      Distne.Net.Hid.add_source(pid, source)
    end)
    Enum.each(1..10, fn(_) ->
      amounts = Enum.map(sources, fn(source) ->
        amount = :random.uniform()
        GenServer.call(source, {:send, pid, {:stim, amount}})
        amount
      end)
      sum = Enum.sum(amounts)
      expected_activation_result = :math.erf(sum)
      Enum.each(sinks, fn(sink) ->
        assert {:ok, {:stim, expected_activation_result}} == GenServer.call(sink, :received)
      end)
    end)
  end
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
    Distne.Net.Con.set_sink(pid, sink)
    Enum.each(1..10, fn (_)  ->
      amount = :random.uniform()
      Distne.Net.Con.stim(pid, amount)
      expected_sink_stim_amount = weight * amount
      assert {:ok, {:stim, expected_sink_stim_amount}} == GenServer.call(sink, :received)
    end)
  end
end

