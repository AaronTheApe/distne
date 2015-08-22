defmodule Distne.Method.Neat.Pop do
  @moduledoc """
  A Pop is a NEAT population of genomes
  """
  use GenServer

  defmodule State do
    defstruct evo_mon: nil, id_gen: nil, genomes: nil, species: nil, task: nil, threshold: nil, fitnesses: nil
  end

  alias Distne.Method.Neat.Pop, as: Pop
  alias Distne.Method.Neat.Species, as: Species
  alias Distne.Method.Neat.IdGen, as: IdGen
  alias Distne.Method.Neat.Genome, as: Genome
  alias Distne.Method.Neat.NodeGene, as: NodeGene
  alias Distne.Method.Neat.ConGene, as: ConGene
  alias Distne.Method.Neat.Evaluator, as: Evaluator

  @doc """
  Starts a new Pop with size genomes, each with numInputs and numOutputs
  """
  def start_link(evo_mon, size, task, numInputs, numOutputs, init_pop_threshold) do
    genomes = Enum.map(1..size, fn(id) ->
      Genome.initial_genome(id, numInputs, numOutputs)
    end)
    species = Species.speciate(genomes, init_pop_threshold)
    next_node_id = numInputs + numOutputs
    next_innov_num = numInputs * numOutputs
    {:ok, id_gen} = IdGen.start_link(next_node_id, next_innov_num)
    GenServer.start_link(Pop, %State{evo_mon: evo_mon, id_gen: id_gen, genomes: genomes, species: species, task: task, threshold: init_pop_threshold})
  end

  def get_genomes(pop) do
    GenServer.call(pop, :get_genomes)
  end

  def get_species(pop) do
    GenServer.call(pop, :get_species)
  end

  def next_gen(pop) do
    GenServer.cast(pop, :next_gen)
  end

  def handle_call(:get_genomes, _from, state) do
    {:reply, {:ok, state.genomes}, state}
  end

  def handle_call(:get_species, _from, state) do
    {:reply, {:ok, state.species}, state}
  end

  def handle_cast(:next_gen, state) do
    Enum.map(state.genomes, fn(genome) ->
      Evaluator.start_link(self, genome, state.task)
    end)
    {:noreply, %State{state| fitnesses: []}}
  end

  def handle_cast({:fitness, genome, fitness}, state) do
    IO.puts "#{genome.id} has fitness #{fitness}"
    if Enum.count(state.fitnesses) + 1 == Enum.count(state.genomes) do
      #determine fitness sharing fitness
      #reproduce
      #speciate
      #update evo_mon
      {:noreply, state}
    else
      {:noreply, %State{state|fitnesses: [{genome, fitness}|state.fitnesses]}}
    end
  end
end
