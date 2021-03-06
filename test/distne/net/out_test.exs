defmodule Distne.Net.OutTest do
  use ExUnit.Case

  alias Distne.Net.Out, as: Out
  alias Distne.Net.TestProbe, as: TestProbe

  test "Out repeatedly erfs the sum of all source stims, and stims its sink with the result" do
    {:ok, pid} = Out.start_link()
    {:ok, sink} = TestProbe.start_link()
    Out.set_sink(pid, sink)
    sources = Enum.map(1..10, fn(_) ->
      {:ok, source} = TestProbe.start_link()
      source
    end)
    Enum.each(sources, fn(source) ->
      Out.add_source(pid, source)
    end)
    Enum.each(1..10, fn(_) ->
      amounts = Enum.map(sources, fn(source) ->
        amount = :rand.uniform()
        GenServer.call(source, {:send, pid, {:stim, source, amount}})
        amount
      end)
      sum = Enum.sum(amounts)
      expected_activation_result = :math.erf(sum)
      TestProbe.assert_receive(sink, {:stim, pid, expected_activation_result}, 100)
    end)
  end
end
