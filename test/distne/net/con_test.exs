defmodule Distne.Net.ConTest do
  use ExUnit.Case

  alias Distne.Net.Con, as: Con
  alias Distne.Net.TestProbe, as: TestProbe
  alias Distne.Net.Stimable, as: Stimable

  test "Con repeatedly forwards {:stim, amount} as {:stim, amount*weight}" do
    weight = :random.uniform()
    {:ok, pid} = Con.start_link(weight)
    {:ok, sink} = TestProbe.start_link()
    Con.set_sink(pid, sink)
    Enum.each(1..10, fn (_)  ->
      amount = :random.uniform()
      Stimable.stim(pid, amount)
      expected_sink_stim_amount = weight * amount
      assert {:ok, {:stim, expected_sink_stim_amount}} == GenServer.call(sink, :received)
    end)
  end
end
