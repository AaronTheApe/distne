defmodule Distne.Method.Neat.PopTest do
  use ExUnit.Case

  #alias Distne.Method.Neat.Genome, as: Genome
  #alias Distne.Method.Neat.IdGen, as: IdGen
  #alias Distne.Method.Neat.ConGene, as: ConGene
  alias Distne.Method.Neat.Pop, as: Pop
  alias Distne.Net.TestProbe, as: TestProbe

  test "initial pop has size genomes" do
    {:ok, evo_mon} = TestProbe.start_link()
    size = 10
    num_inputs = 5
    num_outputs = 1
    init_spec_threshold = 5.0
    task = {:bit_parity, 5}
    {:ok, pop} = Pop.start_link(evo_mon, size, task, num_inputs, num_outputs, init_spec_threshold)
    {:ok, genomes} = Pop.get_genomes(pop)
    assert size == Enum.count(genomes)
  end

  test "initial pop can have 1 species" do
    {:ok, evo_mon} = TestProbe.start_link()
    size = 10
    num_inputs = 5
    num_outputs = 1
    init_spec_threshold = 1000000
    task = {:bit_parity, 5}
    {:ok, pop} = Pop.start_link(evo_mon, size, task, num_inputs, num_outputs, init_spec_threshold)
    {:ok, species} = Pop.get_species(pop)
    assert 1 == Enum.count(species)
  end

  test "initial pop can have 10 species" do
    {:ok, evo_mon} = TestProbe.start_link()
    size = 10
    num_inputs = 5
    num_outputs = 7
    init_spec_threshold = 0
    task = {:bit_parity, 5}
    {:ok, pop} = Pop.start_link(evo_mon, size, task, num_inputs, num_outputs, init_spec_threshold)
    {:ok, species} = Pop.get_species(pop)
    assert 10 == Enum.count(species)
  end

  test "evolve" do
    # {:ok, evo_mon} = TestProbe.start_link()
    # size = 100
    # num_inputs = 2
    # num_outputs = 1
    # init_spec_threshold = 10
    # task = {:bit_parity, 1}
    # {:ok, pop} = Pop.start_link(evo_mon, size, task, num_inputs, num_outputs, init_spec_threshold)
    # Pop.next_gen(pop)
    # :timer.sleep(10000)
  end
end
