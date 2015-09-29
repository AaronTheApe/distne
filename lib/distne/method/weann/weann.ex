defmodule Distne.Method.Weann.Weann do
  use GenServer

  defmodule State do
    defstruct num_inputs: nil, num_hidden: nil, num_outputs: nil, min_weight: -10.0, max_weight: +10.0, mut_rate: nil, mut_std_dev: nil, pop_size: nil, task: nil, client: nil, id_net_evaluator_zip: nil, fitnesses: [], population: nil
  end

  alias Distne.Method.Weann.Weann, as: Weann
  alias Distne.Method.Weann.WeannSettings, as: WeannSettings
  alias Distne.Method.Weann.Genome, as: Genome
  alias Distne.Net.Net, as: Net
  alias Distne.Task.Evaluator, as: Evaluator

  def start_link(settings) do
    GenServer.start_link(Weann, settings)
  end

  def init(settings) do
    state = %State{num_inputs: settings.num_inputs, num_hidden: settings.num_hidden, num_outputs: settings.num_outputs, min_weight: settings.min_weight, max_weight: settings.max_weight, mut_rate: settings.mut_rate, mut_std_dev: settings.mut_std_dev, pop_size: settings.pop_size}
    {:ok, state}
  end

  def solve(pid, task, client) do
    GenServer.cast(pid, {:solve, task, client})
  end

  def perform_generation(pid) do
    GenServer.cast(pid, :perform_generation)
  end

  def perform_reproduction(pid) do
    GenServer.cast(pid, :perform_reproduction)
  end

  def handle_cast({:solve, task, client}, state) do
     population = Enum.map(1..state.pop_size, fn(_) ->
       Genome.random(state.num_inputs, state.num_hidden, state.num_outputs, state.min_weight, state.max_weight)
    end)
     Weann.perform_generation(self)
     {:noreply, %State{state|population: population, task: task, client: client}}
  end

  def handle_cast(:perform_generation, state) do
    id_net_evaluator_zip = Enum.map(state.population, fn(member) ->
      net = Genome.develop(member)
      {:ok, evaluator} = Evaluator.start_link(self)
      Evaluator.evaluate(evaluator, net, state.task)
      {member.id, net, evaluator}
    end)
    {:noreply, %State{state| id_net_evaluator_zip: id_net_evaluator_zip, fitnesses: []}}
  end

  def handle_cast(:perform_reproduction, state) do
    cull_size = div(state.pop_size, 2)
    {cull, selection} = Enum.split(state.fitnesses, cull_size)
    population = Enum.flat_map(selection, fn({id, _})->
      [parent|_] = Enum.filter(state.population, fn(genome)->
        if genome.id == id do
          true
        else
          false
        end
      end)
      offspring = Genome.mutate(parent, state.mut_rate, state.mut_std_dev)
      [parent, offspring]
    end)
    Weann.perform_generation(self)
    {:noreply, %State{state|population: population}}
  end

  def handle_cast({:evaluated, net, fitness}, state) do
    {id, net, evaluator} = List.keyfind(state.id_net_evaluator_zip, net, 1)
    Evaluator.stop(evaluator)
    Net.stop(net)
    fitnesses = [{id, fitness} | state.fitnesses]
    {_w, _x} = Enum.split(fitnesses, 1)
    if Enum.count(fitnesses) == state.pop_size do
      fitnesses = List.keysort(fitnesses, 1)
      {champion_id, champion_fitness} = List.last(fitnesses)
      if champion_fitness > state.task.fitness do
        GenServer.call(state.client, {:solved, champion_fitness, champion_id})
      else
        GenServer.call(state.client, {:not_solved, champion_fitness, champion_id})
        Weann.perform_reproduction(self)
      end
      {:noreply, %State{state| fitnesses: fitnesses}}
    else
      {:noreply, %State{state| fitnesses: fitnesses}}
    end
  end
end
