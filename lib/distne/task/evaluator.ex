defmodule Distne.Task.Evaluator do
  use GenServer

  defmodule State do
    defstruct method: nil, net: nil, task: nil, fitnesses: nil
  end

  alias Distne.Task.Evaluator, as: Evaluator

  def start_link(method) do
    GenServer.start_link(Evaluator, %State{method: method})
  end

  def evaluate(evaluator, net, task) do
    GenServer.cast(evaluator, {:evaluate, net, task})
  end

  def handle_cast({:evaluate, net, task}, state) do
    BitParityMonitor.start_link(task.settings, net, self)
    {:noreply, %State{state|task: task}}
  end

  def handle_cast({:fitness, net, fitness}, state) do
    #Stop the bit parity monitor
    fitnesses = [fitness|State.fitnesses]
    if List.length(fitnesses) ==  state.task.num_trials do
      global_fitness = Enum.sum(fitnesses) / state.task.num_trials
      {:noreply, %State{method: state.method}}
    else
      #Start another bit parity monitor
      {:noreply, %State{state|fitnesses: fitnesses}}
    end
  end
end
