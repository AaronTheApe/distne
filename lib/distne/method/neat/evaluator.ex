defmodule Distne.Method.Neat.Evaluator do
  use GenServer

  defmodule State do
    defstruct pop: nil, genome: nil, net: nil, task: nil
  end

  alias Distne.Method.Neat.Genome, as: Genome
  alias Distne.Method.Neat.Evaluator, as: Evaluator
  alias Distne.Task.BitParity.BitParityMonitor, as: BitParityMonitor
  def start_link(pop, genome, task) do
    {:ok, pid} = GenServer.start_link(Evaluator, %State{pop: pop, genome: genome, task: task})
    Evaluator.evaluate(pid)
    {:ok, pid}
  end

  def evaluate(eval) do
    GenServer.cast(eval, :evaluate)
  end

  def handle_cast(:evaluate, state) do
    {:ok, net} = Genome.develop(state.genome)
    case state.task do
      {:bit_parity, size} ->
        _task = BitParityMonitor.start_link(size, net, self)
    end
    {:noreply, %State{state | net: net}}
  end

  def handle_cast({:fitness, _net, fitness}, state) do
    GenServer.cast(state.pop, {:fitness, state.genome, fitness})
    {:noreply, state}
  end
end
