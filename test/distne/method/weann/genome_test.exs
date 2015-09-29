defmodule Distne.Method.Weann.GenomeTest do
  use ExUnit.Case

  alias Distne.Method.Weann.Genome, as: Genome
  alias Distne.Task.Evaluator, as: Evaluator
  alias Distne.Net.TestProbe, as: TestProbe
  alias Distne.Task.Task, as: Task

  test "generates random genomes of the correct size, that can develop into functioning networks, and be mutated to form other networks" do
    num_inputs = 3
    num_hidden = 10
    num_outputs = 1
    max_weight = 10.0
    min_weight = -10.0
    genome = Genome.random(num_inputs, num_hidden, num_outputs, min_weight, max_weight)
    assert Enum.count(genome.node_genes) == num_inputs + num_hidden + num_outputs
    assert Enum.count(genome.con_genes) == num_inputs * num_hidden + num_hidden * num_outputs

    net = Genome.develop(genome)

    {:ok, method} = TestProbe.start_link
    {:ok, evaluator} = Evaluator.start_link(method)
    settings = %{size: 2}
    task = %Task{name: :bit_parity, settings: settings, num_trials: 10}
    Evaluator.evaluate(evaluator, net, task)
    {:evaluated, net, fitness} = TestProbe.received(method, 100)
    IO.inspect(fitness)

    rate = 0.10
    st_dev = 10.0
    mutated_genome = Genome.mutate(genome, rate, st_dev)
  end
end

