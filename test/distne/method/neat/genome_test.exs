defmodule Distne.Method.Neat.GenomeTest do
  use ExUnit.Case

  alias Distne.Method.Neat.Genome, as: Genome
  alias Distne.Method.Neat.IdGen, as: IdGen
  alias Distne.Method.Neat.ConGene, as: ConGene
  alias Distne.Net.Net, as: Net
  alias Distne.Net.TestProbe, as: TestProbe

  test "initial genome is fully connected inputs to outputs" do
    num_inputs = :rand.uniform(10)
    num_outputs = :rand.uniform(10)
    id = :rand.uniform(10)
    initial_genome = Genome.initial_genome(id, num_inputs, num_outputs)
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

  test "initial_genome develops into functioning network" do
    num_inputs = :rand.uniform(5)
    num_outputs = :rand.uniform(5)
    id = :rand.uniform(10)
    initial_genome = Genome.initial_genome(id, num_inputs, num_outputs)
    {:ok, net} = Genome.develop(initial_genome)
    {:ok, nc} = TestProbe.start_link()
    Net.set_actuator_array(net, nc)
    input_vector = Enum.map(1..num_inputs, fn(_) ->
      :rand.uniform()
    end)
    Net.input_vector(net, input_vector)
    {:output_vector, _output_vector} = TestProbe.received(nc, 100)
    #IO.inspect output_vector
  end

  test "add node mutation test" do
    num_inputs = :rand.uniform(10)
    num_outputs = :rand.uniform(10)
    next_node_id = 23
    next_innov_num = 56
    {:ok, id_gen} = IdGen.start_link(next_node_id, next_innov_num)
    id = :rand.uniform(10)
    initial_genome = Genome.initial_genome(id, num_inputs, num_outputs)
    #Genome.draw(initial_genome, "draw_before_add_node")
    mutated_genome = Genome.add_node(initial_genome, id_gen)
    #Genome.draw(mutated_genome, "draw_after_add_node")
    assert Enum.count(initial_genome.con_genes) + 2 == Enum.count(mutated_genome.con_genes)
    assert Enum.count(initial_genome.node_genes) + 1 == Enum.count(mutated_genome.node_genes)
  end

  test "add con mutation test" do
    num_inputs = :rand.uniform(10)
    num_outputs = :rand.uniform(10)
    next_node_id = 23
    next_innov_num = 56
    {:ok, id_gen} = IdGen.start_link(next_node_id, next_innov_num)
    id = :rand.uniform(10)
    initial_genome = Genome.initial_genome(id, num_inputs, num_outputs)
    #Genome.draw(initial_genome, "draw_before_add_con")
    _mutated_genome = Genome.add_con(initial_genome, id_gen)
    #Genome.draw(mutated_genome, "draw_after_add_con")
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
    genome_1_innovs = [1,2,3,4,6,7,9,10]
    genome_2_innovs = [1,2,4,5,6,8]
    genome_1_con_genes = Enum.map(genome_1_innovs, fn(i) ->
      %ConGene{in: nil, out: nil, weight: nil, enabled: true, innov: i, recursive: false}
    end)
    genome_1 = %Genome{con_genes: genome_1_con_genes}
    genome_2_con_genes = Enum.map(genome_2_innovs, fn(i) ->
      %ConGene{in: nil, out: nil, weight: nil, enabled: true, innov: i, recursive: false}
    end)
    genome_2 = %Genome{con_genes: genome_2_con_genes}
    {excess_in_1, excess_in_2} = Genome.excess(genome_1, genome_2)
    excess_in_1_innovs = Enum.map(excess_in_1, fn(cg) -> cg.innov end)
    expected_excess_in_1_innovs = [9,10]
    excess_in_2_innovs = Enum.map(excess_in_2, fn(cg) -> cg.innov end)
    expected_excess_in_2_innovs = []
    assert expected_excess_in_1_innovs == excess_in_1_innovs
    assert expected_excess_in_2_innovs == excess_in_2_innovs
  end

  test "average weight difference" do
    genome_1_innovs_and_weights = [{1, 3.5}, {3, 5.6}, {5, -15.2}]
    genome_2_innovs_and_weights = [{2, 4.2}, {3, -3.0}, {4, 1.5}, {5, 7.3}, {6, 1.0}]
    genome_1_con_genes = Enum.map(genome_1_innovs_and_weights, fn({i, w}) ->
      %ConGene{in: nil, out: nil, weight: w, enabled: true, innov: i, recursive: false}
    end)
    genome_1 = %Genome{con_genes: genome_1_con_genes}
    genome_2_con_genes = Enum.map(genome_2_innovs_and_weights, fn({i, w}) ->
      %ConGene{in: nil, out: nil, weight: w, enabled: true, innov: i, recursive: false}
    end)
    genome_2 = %Genome{con_genes: genome_2_con_genes}
    expected_avg_weight_diff = (abs(5.6 - (-3.0)) + abs(-15.2 - 7.3)) / 2.0
    actual_avg_weight_diff = Genome.avg_weight_diff(genome_1, genome_2)
    assert expected_avg_weight_diff == actual_avg_weight_diff
  end

  test "distance" do
    genome_1_innovs_and_weights = [{1, 3.5}, {3, 5.6}, {5, -15.2}]
    genome_2_innovs_and_weights = [{2, 4.2}, {3, -3.0}, {4, 1.5}, {5, 7.3}, {6, 1.0}]
    genome_1_con_genes = Enum.map(genome_1_innovs_and_weights, fn({i, w}) ->
      %ConGene{in: nil, out: nil, weight: w, enabled: true, innov: i, recursive: false}
    end)
    genome_1 = %Genome{con_genes: genome_1_con_genes}
    genome_2_con_genes = Enum.map(genome_2_innovs_and_weights, fn({i, w}) ->
      %ConGene{in: nil, out: nil, weight: w, enabled: true, innov: i, recursive: false}
    end)
    genome_2 = %Genome{con_genes: genome_2_con_genes}
    w = (abs(5.6 - (-3.0)) + abs(-15.2 - 7.3)) / 2.0
    n = 5
    e = 1
    d = 3
    c1 = Application.get_env(:neat, :c1)
    c2 = Application.get_env(:neat, :c2)
    c3 = Application.get_env(:neat, :c3)
    expected_distance = c1*e/n + c2*d/n + c3*w
    actual_distance = Genome.distance(genome_1, genome_2)
    assert expected_distance == actual_distance
  end

  test "adjusted fitness" do
  end

  test "draw graph" do
    # num_inputs = :rand.uniform(10)
    # num_outputs = :rand.uniform(10)
    # initial_genome = Genome.initial_genome(num_inputs, num_outputs)
    # Genome.draw(initial_genome, "draw")
  end
end
