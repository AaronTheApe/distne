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
      :timer.sleep(1)
      expected_sink_stim_amount = weight * amount
      expected_sink_stim = {:stim, pid, expected_sink_stim_amount}
      TestProbe.assert_receive(sink, expected_sink_stim, 100)
    end)
  end
end
