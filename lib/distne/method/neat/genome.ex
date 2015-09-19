defmodule Distne.Method.Neat.Genome do
  defstruct id: nil, con_genes: HashSet.new, node_genes: HashSet.new

  alias Distne.Method.Neat.Genome, as: Genome
  alias Distne.Method.Neat.IdGen, as: IdGen
  alias Distne.Method.Neat.ConGene, as: ConGene
  alias Distne.Method.Neat.NodeGene, as: NodeGene
  alias Distne.Net.Net, as: Net

  def initial_genome(id, num_inputs, num_outputs) do
    inputs = Enum.into(Enum.map(0..num_inputs-1, fn(x) ->
      %NodeGene{node: x, type: :sensor}
    end), HashSet.new)
    outputs = Enum.into(Enum.map(num_inputs .. num_inputs+num_outputs-1, fn(x) ->
      %NodeGene{node: x, type: :output}
    end), HashSet.new)
    node_genes = HashSet.union(inputs, outputs)
    con_genes_out_of_set = Enum.flat_map(inputs, fn(input) ->
      Enum.map(outputs, fn(output) ->
        weight = (:rand.uniform() - 0.5) * 10.0
        %ConGene{in: input.node, out: output.node, weight: weight , enabled: true, innov: 1, recursive: false}
      end)
    end)
    con_genes_with_innovs =
      Enum.with_index(con_genes_out_of_set) |> Enum.map(fn({con, i}) ->
          %ConGene{con | innov: i}
      end)
    con_genes =
      Enum.into(
        con_genes_with_innovs,
        HashSet.new)
    %Genome{id: id, node_genes: node_genes, con_genes: con_genes}
  end

  def add_node(genome, id_gen) do
    con_to_disable = Enum.at(genome.con_genes, :rand.uniform(HashSet.size(genome.con_genes) - 1))
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
          {Enum.at(potential_ins, :rand.uniform(length(potential_ins))),
           Enum.at(potential_outs, :rand.uniform(length(potential_outs)))}
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
    new_con_gene = %ConGene{in: input, out: output, weight: :rand.uniform, enabled: true, innov: innov_num, recursive: false}
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

  def disjoint(g1, g2) do
    innovs_1 = Enum.map(g1.con_genes, fn(cg) -> cg.innov end)
    innovs_2 = Enum.map(g2.con_genes, fn(cg) -> cg.innov end)
    max_innovs_1 = Enum.max(innovs_1)
    max_innovs_2 = Enum.max(innovs_2)
    disjoint_1 = Enum.filter(g1.con_genes, fn(cg) ->
      !Enum.member?(innovs_2, cg.innov) && cg.innov < max_innovs_2
    end)
    disjoint_2 = Enum.filter(g2.con_genes, fn(cg) ->
      !Enum.member?(innovs_1, cg.innov) && cg.innov < max_innovs_1
    end)
    {disjoint_1, disjoint_2}
  end

  def excess(g1, g2) do
    innovs_1 = Enum.map(g1.con_genes, fn(cg) -> cg.innov end)
    innovs_2 = Enum.map(g2.con_genes, fn(cg) -> cg.innov end)
    max_innovs_1 = Enum.max(innovs_1)
    max_innovs_2 = Enum.max(innovs_2)
    excess_1 = Enum.filter(g1.con_genes, fn(cg) ->
      !Enum.member?(innovs_2, cg.innov) && cg.innov > max_innovs_2
    end)
    excess_2 = Enum.filter(g2.con_genes, fn(cg) ->
      !Enum.member?(innovs_1, cg.innov) && cg.innov > max_innovs_1
    end)
    {excess_1, excess_2}
  end

  defp matching(g1, g2) do
    innovs_1 = Enum.map(g1.con_genes, fn(cg) -> cg.innov end)
    innovs_2 = Enum.map(g2.con_genes, fn(cg) -> cg.innov end)
    common_genes_1 = Enum.filter(g1.con_genes, fn(cg) ->
      Enum.member?(innovs_2, cg.innov)
    end)
    common_genes_2 = Enum.filter(g2.con_genes, fn(cg) ->
      Enum.member?(innovs_1, cg.innov)
    end)
    {common_genes_1, common_genes_2}
  end

  def avg_weight_diff(g1, g2) do
    {m1, m2} = matching(g1, g2)
    Enum.sum(
      Enum.map(Enum.zip(m1, m2), fn({cg1, cg2}) ->
        abs(cg1.weight - cg2.weight)
      end)) / Enum.count(m1)
  end

  def distance(g1, g2) do
    c1 = Application.get_env(:neat, :c1)
    c2 = Application.get_env(:neat, :c2)
    c3 = Application.get_env(:neat, :c3)
    {e1, e2} = excess(g1, g2)
    e = max(Enum.count(e1), Enum.count(e2))
    {d1, d2} = disjoint(g1, g2)
    d = Enum.count(d1) + Enum.count(d2)
    n = max(Enum.count(g1.con_genes), Enum.count(g2.con_genes))
    w = avg_weight_diff(g1, g2)
    c1*e/n + c2*d/n + c3*w
  end

  def develop(genome) do
    {:ok, net} = Net.start_link()

    nodes = Enum.into(Enum.map(genome.node_genes, fn(ng) ->
      case ng.type do
        :sensor ->
          {:ok, input} = Net.add_in(net)
          {ng.node, input}
        :hidden ->
          {:ok, hidden} = Net.add_hid(net)
          {ng.node, hidden}
        :output ->
          {:ok, output} = Net.add_out(net)
          {ng.node, output}
      end
    end), %{})

    Enum.map(genome.con_genes, fn(cg) ->
      Net.connect(net, Map.get(nodes, cg.in), Map.get(nodes, cg.out), cg.weight)
    end)

    {:ok, net}
  end
end
