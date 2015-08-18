defmodule Distne.Method.Neat.Pop do
  @moduledoc """
  A Pop is a NEAT population of genomes
  """
  use GenServer

  require Record
  Record.defrecordp :state, genomes: nil, species: nil, threshold: nil

  alias Distne.Method.Neat.Pop, as: Pop
  alias Distne.Method.Neat.Species, as: Species
  alias Distne.Method.Neat.IdGen, as: IdGen
  alias Distne.Method.Neat.Genome, as: Genome
  alias Distne.Method.Neat.NodeGene, as: NodeGene
  alias Distne.Method.Neat.ConGene, as: ConGene

  @doc """
  Starts a new Pop with size genomes, each with numInputs and numOutputs
  """
  def start_link(size, numInputs, numOutputs, init_pop_threshold) do
    genomes = Enum.map(1..size, fn(_) ->
      Genome.initial_genome(numInputs, numOutputs)
    end)
    species = Species.speciate(genomes, init_pop_threshold)
    GenServer.start_link(Pop, state(genomes: genomes, species: species, threshold: init_pop_threshold))
  end

  def get_genomes(pop) do
    GenServer.call(pop, :get_genomes)
  end

  def get_species(pop) do
    GenServer.call(pop, :get_species)
  end

  def handle_call(:get_genomes, _from, state) do
    {:reply, {:ok, state(state, :genomes)}, state}
  end

  def handle_call(:get_species, _from, state) do
    {:reply, {:ok, state(state, :species)}, state}
  end
end
