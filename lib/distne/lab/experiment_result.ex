defmodule Distne.Lab.ExperimentResult do
  defstruct treatment_results: nil

  alias Distne.Lab.TreatmentResult, as: TreatmentResult

  def puts(experiment_result) do

    IO.puts "\n\nname, cpu_time, gens, tasks\n"
    Enum.each(experiment_result.treatment_results, fn(ts) ->
      TreatmentResult.puts(ts)
    end)
  end
end
