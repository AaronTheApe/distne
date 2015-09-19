defmodule Distne.Method.Neat.Species do
  defstruct id: nil, rep: nil, members: nil

  alias Distne.Method.Neat.Species, as: Species
  alias Distne.Method.Neat.Genome, as: Genome

  def speciate([head| tail], threshold) do
    speciate_spp([%Species{id: 1, rep: head, members: [head]}], tail, threshold)
  end

  def speciate_spp(spp, [], _threshold) do
    spp
  end

  def speciate_spp(spp, [genome | genomes], threshold) do
    speciate_spp(add_genome([], spp, genome, threshold), genomes, threshold)
  end

  def add_genome(tried, [], genome, _threshold) do
    [%Species{id: 1, rep: genome, members: [genome]}|tried]
  end

  def add_genome(tried, [sp|spp], genome, threshold) do
    if Genome.distance(sp.rep, genome) < threshold do
      updated_sp = %Species{sp | members: [genome|sp.members]}
      tried ++ [updated_sp | spp]
    else
      add_genome([sp | tried], spp, genome, threshold)
    end
  end

end
