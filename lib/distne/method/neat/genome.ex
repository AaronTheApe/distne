defmodule Distne.Method.Neat.Genome do
  defstruct con_genes: HashSet.new, node_genes: HashSet.new

  alias Distne.Method.Neat.Genome, as: Genome
  alias Distne.Method.Neat.IdGen, as: IdGen
  alias Distne.Method.Neat.ConGene, as: ConGene
  alias Distne.Method.Neat.NodeGene, as: NodeGene

  def initial_genome(num_inputs, num_outputs) do
    inputs = Enum.into(Enum.map(1..num_inputs, fn(x) ->
      %{node: x, type: :sensor}
    end), HashSet.new)
    outputs = Enum.into(Enum.map(num_inputs + 1 .. num_inputs+num_outputs, fn(x) ->
      %NodeGene{node: x, type: :output}
    end), HashSet.new)
    node_genes = HashSet.union(inputs, outputs)
    con_genes_out_of_set = Enum.flat_map(inputs, fn(input) ->
      Enum.map(outputs, fn(output) ->
        %ConGene{in: input.node, out: output.node, weight: :random.uniform(10), enabled: true, innov: 1, recursive: false}
      end)
    end)
    IO.puts Enum.count(con_genes_out_of_set)
    con_genes =
      Enum.into(
        con_genes_out_of_set,
        HashSet.new)
    %Genome{node_genes: node_genes, con_genes: con_genes}
  end

  def add_node(genome, id_gen) do
    con_to_disable = Enum.at(genome.con_genes, :random.uniform(HashSet.size(genome.con_genes) - 1))
    disabled_con = %ConGene{con_to_disable | enabled: false}
    {:ok, node_id} = IdGen.node_id(id_gen, con_to_disable.in, con_to_disable.out)
    new_node_gene = %NodeGene{node: node_id, type: :hidden}
    {:ok, in_con_innov_num} = IdGen.innov_num(id_gen, con_to_disable.in, node_id)
    in_con_gene = %ConGene{in: con_to_disable.in, out: node_id, weight: 1.0, enabled: true, innov: in_con_innov_num, recursive: false}
    {:ok, out_con_innov_num} = IdGen.innov_num(id_gen, node_id, con_to_disable.out)
    out_con_gene = %ConGene{in: node_id, out: con_to_disable.out, weight: con_to_disable.weight, enabled: true, innov: out_con_innov_num, recursive: false}
    new_con_genes3 = HashSet.delete(genome.con_genes, con_to_disable)
    new_con_genes2 = HashSet.put(new_con_genes3, disabled_con)
    new_con_genes1 = HashSet.put(new_con_genes2, in_con_gene)
    new_con_genes = HashSet.put(new_con_genes1, out_con_gene)
    new_node_genes = HashSet.put(genome.node_genes, new_node_gene)
    %Genome{node_genes: new_node_genes, con_genes: new_con_genes}
  end

  def add_con(genome, id_gen) do
    node_genes = genome.node_genes
    potential_ins =
      Enum.map(
        node_genes,
        fn(y) ->
          y.node
        end)
    potential_outs =
      Enum.map(
        Enum.filter(node_genes, fn(x) ->
          x.type == :output || x.type == :hidden
        end),
        fn(y) ->
          y.node
        end)
    potential_cons =
      Stream.repeatedly(
        fn ->
          {Enum.at(potential_ins, :random.uniform(length(potential_ins))),
           Enum.at(potential_outs, :random.uniform(length(potential_outs)))}
       end)
    existing_cons = Enum.map(genome.con_genes, fn(x) ->
      {x.in, x.out}
    end)
    {input, output} = Enum.find(potential_cons, nil, fn({input,output}) ->
      nil == Enum.find(existing_cons, nil, fn({input2, output2}) ->
        input == input2 && output == output2
      end)
    end)
    {:ok, innov_num} = IdGen.innov_num(id_gen, input, output)
    new_con_gene = %ConGene{in: input, out: output, weight: :random.uniform, enabled: true, innov: innov_num, recursive: false}
    new_con_genes = HashSet.put(genome.con_genes, new_con_gene)
    %Genome{node_genes: node_genes, con_genes: new_con_genes}
  end

  def draw(genome, filename) do
    {:ok, file} = File.open filename, [:write]
    IO.puts file, "digraph G {"
    Enum.each(genome.con_genes, fn(cg) ->
      con_string = Integer.to_string(cg.in) <> " -> " <> Integer.to_string(cg.out)
      con_string_with_opts = con_string
      if !cg.enabled do
        con_string_with_opts = con_string_with_opts <> " [style=dashed]"
      end
      IO.puts file, con_string_with_opts
    end)
    Enum.each(genome.node_genes, fn(ng) ->
      if ng.type == :hidden do
        IO.puts file, "#{ng.node} [color=red]"
      end
      if ng.type == :sensor do
        IO.puts file, "#{ng.node} [color=green]"
      end
      if ng.type == :output do
        IO.puts file, "#{ng.node} [color=blue]"
      end
    end)
    IO.puts file, "}"
    System.cmd("dot", ["-Tsvg", "-O", filename])
  end
end
