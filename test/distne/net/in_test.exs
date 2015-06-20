defmodule Distne.Net.InTest do
  use ExUnit.Case

  alias Distne.Net.In, as: In
  alias Distne.Net.TestProbe, as: TestProbe
  alias Distne.Net.Stimable, as: Stimable

  test "Input repeatedly forwards {:stim, amount} to its sinks" do
    {:ok, pid} = In.start_link()
    sinks = Enum.map(1..10, fn(_) ->
      {:ok, sink} = TestProbe.start_link()
      sink
    end)
    Enum.each(sinks, fn(sink) ->
      In.add_sink(pid, sink)
    end)
    amount = :random.uniform()
    Stimable.stim(pid, amount)
    Enum.each(sinks, fn(sink) ->
      assert {:ok, {:stim, amount}} == GenServer.call(sink, :received)
    end)
  end
end
