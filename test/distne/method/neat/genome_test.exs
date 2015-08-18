defmodule Distne.Method.Neat.GenomeTest do
  use ExUnit.Case

  alias Distne.Method.Neat.Genome, as: Genome
  alias Distne.Method.Neat.IdGen, as: IdGen
  alias Distne.Method.Neat.ConGene, as: ConGene

  test "initial genome is fully connected inputs to outputs" do
    num_inputs = :random.uniform(10)
    num_outputs = :random.uniform(10)
    initial_genome = Genome.initial_genome(num_inputs, num_outputs)
    assert num_inputs + num_outputs ==  Set.size(initial_genome.node_genes)
    assert num_inputs + num_outputs ==
      HashSet.size(
        Enum.into(
          Enum.map(
            initial_genome.node_genes, fn(n) ->
              n.node
            end),
            HashSet.new
        )
      )
    assert num_inputs ==
      Enum.count(
        Enum.filter(
          initial_genome.node_genes,
          fn(n) ->
            n.type == :sensor
          end
        )
      )
    assert num_outputs ==
      Enum.count(
        Enum.filter(
          initial_genome.node_genes,
          fn(n) ->
            n.type == :output
          end
        )
      )
    assert num_outputs * num_inputs == Enum.count(initial_genome.con_genes)
    assert num_inputs * num_outputs ==
      Enum.count(
        Enum.into(
          Enum.map(
            initial_genome.con_genes,
            fn(c) ->
              Integer.to_string(c.in) <> Integer.to_string(c.out)
            end),
          HashSet.new
        )
      )
  end

  test "add node mutation test" do
    num_inputs = :random.uniform(10)
    num_outputs = :random.uniform(10)
    next_node_id = 23
    next_innov_num = 56
    {:ok, id_gen} = IdGen.start_link(next_node_id, next_innov_num)
    initial_genome = Genome.initial_genome(num_inputs, num_outputs)
    #IO.inspect initial_genome
    Genome.draw(initial_genome, "draw_before_add_node")
    mutated_genome = Genome.add_node(initial_genome, id_gen)
    #IO.inspect mutated_genome
    Genome.draw(mutated_genome, "draw_after_add_node")
    assert Enum.count(initial_genome.con_genes) + 2 == Enum.count(mutated_genome.con_genes)
    assert Enum.count(initial_genome.node_genes) + 1 == Enum.count(mutated_genome.node_genes)
  end

  test "add con mutation test" do
    num_inputs = :random.uniform(10)
    num_outputs = :random.uniform(10)
    next_node_id = 23
    next_innov_num = 56
    {:ok, id_gen} = IdGen.start_link(next_node_id, next_innov_num)
    initial_genome = Genome.initial_genome(num_inputs, num_outputs)
    #IO.inspect initial_genome
    Genome.draw(initial_genome, "draw_before_add_con")
    mutated_genome = Genome.add_con(initial_genome, id_gen)
    #IO.inspect mutated_genome
    Genome.draw(mutated_genome, "draw_after_add_con")
  end

  test "cross" do
  end

  test "disjoint" do
    genome_1_innovs = [1,2,3,4,6,7]
    genome_2_innovs = [1,2,4,5,6,8]
    genome_1_con_genes = Enum.map(genome_1_innovs, fn(i) ->
      %ConGene{in: nil, out: nil, weight: nil, enabled: true, innov: i, recursive: false}
    end)
    genome_1 = %Genome{con_genes: genome_1_con_genes}
    genome_2_con_genes = Enum.map(genome_2_innovs, fn(i) ->
      %ConGene{in: nil, out: nil, weight: nil, enabled: true, innov: i, recursive: false}
    end)
    genome_2 = %Genome{con_genes: genome_2_con_genes}
    {only_in_1, only_in_2} = Genome.disjoint(genome_1, genome_2)
    only_in_1_innovs = Enum.map(only_in_1, fn(cg) -> cg.innov end)
    expected_only_in_1_innovs = [3, 7]
    only_in_2_innovs = Enum.map(only_in_2, fn(cg) -> cg.innov end)
    expected_only_in_2_innovs = [5]
    assert expected_only_in_1_innovs == only_in_1_innovs
    assert expected_only_in_2_innovs == only_in_2_innovs
  end

  test "excess" do
  end

  test "average weight" do
  end

  test "adjusted fitness" do
  end

  test "draw graph" do
    num_inputs = :random.uniform(10)
    num_outputs = :random.uniform(10)
    initial_genome = Genome.initial_genome(num_inputs, num_outputs)
    Genome.draw(initial_genome, "draw")
  end
end
