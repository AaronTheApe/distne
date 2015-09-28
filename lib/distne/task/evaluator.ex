defmodule Distne.Task.Evaluator do
  use GenServer

  defmodule State do
    defstruct method: nil, net: nil, task: nil, fitnesses: nil, monitor: nil
  end

  alias Distne.Task.Evaluator, as: Evaluator
  alias Distne.Task.BitParity.BitParityMonitor, as: BitParityMonitor

  def start_link(method) do
    GenServer.start_link(Evaluator, %State{method: method})
  end

  def evaluate(evaluator, net, task) do
    GenServer.cast(evaluator, {:evaluate, net, task})
  end

  def stop(evaluator) do
    GenServer.call(evaluator, :stop)
  end

  def handle_cast({:evaluate, net, task}, state) do
    {:ok, monitor} = BitParityMonitor.start_link(task.settings, net, self)
    {:noreply, %State{state|task: task, fitnesses: [], net: net, monitor: monitor}}
  end

  def handle_cast({:fitness, net, fitness}, state) do
    BitParityMonitor.stop(state.monitor)
    fitnesses = [fitness|state.fitnesses]
    if Enum.count(fitnesses) ==  state.task.num_trials do
      global_fitness = Enum.sum(fitnesses) / state.task.num_trials
      GenServer.cast(state.method, {:evaluated, state.net, global_fitness})
      {:noreply, %State{method: state.method, fitnesses: [], monitor: nil}}
    else
      {:ok, monitor} = BitParityMonitor.start_link(state.task.settings, state.net, self)      
      {:noreply, %State{state|fitnesses: fitnesses, monitor: monitor}}
    end
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

end
