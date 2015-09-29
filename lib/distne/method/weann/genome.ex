defmodule Distne.Method.Weann.Genome do
  defstruct node_genes: nil, con_genes: nil

  alias Distne.Method.Weann.NodeGene, as: NodeGene
  alias Distne.Method.Weann.ConGene, as: ConGene
  alias Distne.Method.Weann.Genome, as: Genome
  alias Distne.Net.Net, as: Net

  def random(num_inputs, num_hidden, num_outputs, min_weight, max_weight) do
    first_input_id = 1
    last_input_id = num_inputs
    inputs = Enum.map(first_input_id..last_input_id, fn(id) ->
      %NodeGene{id: id, type: :input}
    end)
    first_hidden_id = last_input_id + 1
    last_hidden_id = last_input_id + num_hidden
    hidden = Enum.map(first_hidden_id..last_hidden_id, fn(id) ->
      %NodeGene{id: id, type: :hidden}
    end)
    first_output_id = last_hidden_id + 1
    last_output_id = last_hidden_id + num_outputs
    outputs = Enum.map(first_output_id..last_output_id, fn(id) ->
      %NodeGene{id: id, type: :output}
    end)
    node_genes = inputs ++ hidden ++ outputs
    input_layer = Enum.flat_map(inputs, fn(input) ->
      Enum.map(hidden, fn(hid) ->
        %ConGene{in: input.id, out: hid.id, weight: random_weight(min_weight, max_weight)}
      end)
    end)
    output_layer = Enum.flat_map(hidden, fn(hid) ->
      Enum.map(outputs, fn(output) ->
        %ConGene{in: hid.id, out: output.id, weight: random_weight(min_weight, max_weight)}
      end)
    end)
    con_genes = input_layer ++ output_layer
    %Genome{node_genes: node_genes, con_genes: con_genes}
  end

  def random_weight(min_weight, max_weight) do
    min_weight + :rand.uniform * (max_weight - min_weight)
  end

  def develop(genome) do
    {:ok, net} = Net.start_link
    id_node_zip = Enum.map(genome.node_genes, fn(ng) ->
      {:ok, node} = case ng.type do
                      :input -> Net.add_in(net)
                      :hidden -> Net.add_hid(net)
                      _ -> Net.add_out(net)
                    end
      {ng.id, node}
    end)
    Enum.each(genome.con_genes, fn(cg) ->
      {_, source} = List.keyfind(id_node_zip, cg.in, 0)
      {_, sink} = List.keyfind(id_node_zip, cg.out, 0)
      Net.connect(net, source, sink, cg.weight)
    end)
    net
  end

  def mutate(genome, rate, st_dev) do
    new_con_genes = Enum.map(genome.con_genes, fn(cg) ->
      if :rand.uniform < rate do
        %ConGene{cg|weight: cg.weight + :rand.normal * st_dev}
      else
        cg
      end
    end)
    %Genome{genome|con_genes: new_con_genes}
  end
end
