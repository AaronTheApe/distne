defmodule Distne.Net.InTest do
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
    Distne.Net.Stimable.stim(pid, amount)
    Enum.each(sinks, fn(sink) ->
      assert {:ok, {:stim, amount}} == GenServer.call(sink, :received)
    end)
  end
end
