defmodule DistneTest do
  use ExUnit.Case

  import Distne.Net.Con
  import Distne.Net.TestProbe

  test "Con forwards {:stim, amount} as {:stim, amount*weight}" do
    {:ok, pid} = Distne.Net.Con.start_link(3.14)
    {:ok, sink} = Distne.Net.TestProbe.start_link()
    :ok = GenServer.call(pid, {:set_sink, sink})
    GenServer.call(pid, {:stim, 2.0})
    {:ok, {:stim, 2.0 * 3.14}} = GenServer.call(sink, :received)
    #//GenServer.call(:add_sink, )
  end
end

