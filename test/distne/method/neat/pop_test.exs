defmodule Distne.Method.Neat.PopTest do
  use ExUnit.Case

  alias Distne.Method.Neat.Genome, as: Genome
  alias Distne.Method.Neat.IdGen, as: IdGen
  alias Distne.Method.Neat.ConGene, as: ConGene
  alias Distne.Method.Neat.Pop, as: Pop

  test "initial pop hax size genomes" do
    size = 10
    num_inputs = 5
    num_outputs = 7
    init_spec_threshold = 5.0
    {:ok, pop} = Pop.start_link(size, num_inputs, num_outputs, init_spec_threshold)
    {:ok, genomes} = Pop.get_genomes(pop)
    assert size == Enum.count(genomes)
  end

  test "initial pop can have 1 species" do
    size = 10
    num_inputs = 5
    num_outputs = 7
    init_spec_threshold = 1000000
    {:ok, pop} = Pop.start_link(size, num_inputs, num_outputs, init_spec_threshold)
    {:ok, species} = Pop.get_species(pop)
    assert 1 == Enum.count(species)
  end

  test "initial pop can have 10 species" do
    size = 10
    num_inputs = 5
    num_outputs = 7
    init_spec_threshold = 0
    {:ok, pop} = Pop.start_link(size, num_inputs, num_outputs, init_spec_threshold)
    {:ok, species} = Pop.get_species(pop)
    assert 10 == Enum.count(species)
  end
end
