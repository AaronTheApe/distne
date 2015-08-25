defmodule Distne.Lab.TreatmentResult do
  defstruct treatment_name: nil, cpu_time: nil, generations: nil, tasks: nil

  def puts(treatment_result) do
    IO.puts "#{treatment_result.treatment_name}, " <>
      "#{treatment_result.cpu_time}, " <>
      "#{treatment_result.generations}, " <>
      "#{treatment_result.tasks}"
  end
end
