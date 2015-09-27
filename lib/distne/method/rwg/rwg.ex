defmodule Distne.Method.Rwg.Rwg do
  use GenServer

  defmodule State do
    defstruct num_inputs: nil, num_hidden: nil, num_outputs: nil
  end

  alias Distne.Method.Rwg.Rwg, as: Rwg

  def start_link(settings) do
    GenServer.start_link(
      Rwg,
      %State{num_inputs: settings.num_inputs, num_hidden: settings.num_hidden, num_outputs: settings.num_outputs})
  end

  def solve(pid, task) do
  end
end
