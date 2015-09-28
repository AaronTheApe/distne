defmodule Distne do
  alias Distne.Lab.Lab, as: Lab
  alias Distne.Lab.Experiment, as: Experiment
  alias Distne.Lab.Treatment, as: Treatment
  alias Distne.Task.Task, as: Task

  def main(_args) do
    {:ok, experiment} = formulate_experiment
    {:ok, lab} = Lab.start_link
    Lab.perform_experiment(lab, experiment)
    :timer.sleep(100000)
  end

  def formulate_experiment do
    IO.puts "Formulating experiment..."
    name = "rwg_big_vs_rwg_small"
    treatments = [
      %Treatment{name: "rwg_big", method: :rwg,
        settings: %{num_inputs: 3, num_hidden: 20, num_outputs: 1, min_weight: -10.0, max_weight: 10.0}},
      %Treatment{name: "rwg_small", method: :rwg,
        settings: %{num_inputs: 3, num_hidden: 1, num_outputs: 1, min_weight: -10.0, max_weight: 10.0}}
    ]
    task = %Task{name: :bit_parity, settings: %{size: 2}, num_trials: 5, fitness: 0.91}
    sample_size = 2
    experiment = %Experiment{
      name: name, treatments: treatments, task: task, sample_size: sample_size}
    {:ok, experiment}
  end
end
