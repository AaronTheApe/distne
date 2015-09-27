defmodule Distne.Method.Rwg.Rwg do
  use GenServer

  defmodule State do
    defstruct num_inputs: nil, num_hidden: nil, num_outputs: nil, min: -10, max: +10
  end

  alias Distne.Method.Rwg.Rwg, as: Rwg
  alias Distne.Net.Net, as: Net

  def start_link(settings) do
    GenServer.start_link(
      Rwg,
      %State{num_inputs: settings.num_inputs, num_hidden: settings.num_hidden, num_outputs: settings.num_outputs})
  end

  def solve(pid, task) do
    GenServer.cast(pid, {:solve, task})
  end

  def handle_cast({:solve, task}, state) do
    net = random_net(state)
    {:noreply, state}
  end

  def random_net(state) do
    {:ok, net} = Net.start_link
    inputs = Enum.map(1..state.num_inputs,
      fn(_) ->
        {:ok, input} = Net.add_in(net)
        input
      end)
    hidden = Enum.map(1..state.num_hidden,
      fn(_) ->
        {:ok, hid} = Net.add_hid(net)
        hid
      end)
    outputs = Enum.map(1..state.num_outputs,
      fn(_) ->
        {:ok, output} = Net.add_out(net)
        output
      end)
    Enum.each(inputs,
      fn(input) ->
        Enum.each(hidden,
          fn(hid) ->
            Net.connect(net, input, hid, random_weight(state))
          end
        )
      end)
    Enum.each(hidden,
      fn(hid) ->
        Enum.each(outputs,
          fn(output) ->
            Net.connect(net, hid, output, random_weight(state))
          end
        )
      end)
    net
  end

  def random_weight(state) do
    range = state.max - state.min
    state.min + (:rand.uniform * range)
  end
end
