defmodule Distne.Lab.ExperimentResult do
  defstruct treatment_results: nil

  alias Distne.Lab.ExperimentResult, as: ExperimentResult
  alias Distne.Lab.TreatmentResult, as: TreatmentResult

  def puts(experiment_result) do
    IO.puts "treatment_name, cpu_time, generations, tasks"
    Enum.each(experiment_result.treatment_results, fn(ts) ->
      TreatmentResult.puts(ts)
    end)
  end
end