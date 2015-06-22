defmodule Distne.Net.HidTest do
  use ExUnit.Case

  alias Distne.Net.Hid, as: Hid
  alias Distne.Net.TestProbe, as: TestProbe

  test "hid repeatedly erfs the sum of all source stims, and stims all of its sinks with the result" do
    {:ok, pid} = Hid.start_link()
    sinks = Enum.map(1..10, fn(_) ->
      {:ok, sink} = TestProbe.start_link()
      sink
    end)
    Enum.each(sinks, fn(sink) ->
      Hid.add_sink(pid, sink)
    end)
    sources = Enum.map(1..10, fn(_) ->
      {:ok, source} = TestProbe.start_link()
      source
    end)
    Enum.each(sources, fn(source) ->
      Hid.add_source(pid, source)
    end)
    Enum.each(1..10, fn(_) ->
      amounts = Enum.map(sources, fn(source) ->
        amount = :random.uniform()
        GenServer.call(source, {:send, pid, {:stim, source, amount}})
        amount
      end)
      sum = Enum.sum(amounts)
      expected_activation_result = :math.erf(sum)
      :timer.sleep(100)
      Enum.each(sinks, fn(sink) ->
        assert {:ok, {:stim, pid, expected_activation_result}} == GenServer.call(sink, :received)
      end)
    end)
  end
end
