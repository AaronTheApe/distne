defmodule Distne.Lab.LabTest do
  use ExUnit.Case

  alias Distne.Lab.Experiment, as: Experiment
  alias Distne.Lab.ExperimentResult, as: ExperimentResult
  alias Distne.Lab.Lab, as: Lab
  alias Distne.Task.Task, as: Task
  alias Distne.Lab.Treatment, as: Treatment
  alias Distne.Lab.TreatmentResult, as: TreatmentResult
  alias Distne.Net.TestProbe, as: TestProbe

  test "A Lab is started with no args and has a tech process, but no experiment results" do
    {:ok, lab} = Lab.start_link
    {:ok, tech} = Lab.get_tech(lab)
    assert is_pid tech
    {:ok, experiment_results} = Lab.get_experiment_results(lab)
    assert [] == experiment_results
  end

  test "A Lab performs experiments by delegating it to its tech process" do
    {:ok, lab} = Lab.start_link
    {:ok, tech} = TestProbe.start_link
    :ok = Lab.set_tech(lab, tech)
    name = "rwg_vs_weann"
    treatments = [
      %Treatment{name: "rwg", method: :rwg, settings: %{num_inputs: 2}},
      %Treatment{name: "weann", method: :weann, settings: %{num_inputs: 3}}
    ]
    task = %Task{name: :bit_parity, settings: %{bits: 3}, num_trials: 10}
    sample_size = 50
    experiment = %Experiment{
      name: name, treatments: treatments, task: task, sample_size: sample_size}
    Lab.perform_experiment(lab, experiment)
    TestProbe.assert_receive(tech, {:perform_experiment, experiment}, 100)
    treatment_results = [
      %TreatmentResult{
        treatment_name: "rwg",
        cpu_time: 200.2,
        generations: 80,
        tasks: 300
      },
      %TreatmentResult{
        treatment_name: "weann",
        cpu_time: 100.6,
        generations: 40,
        tasks: 127
      }
    ]
    experiment_result = %ExperimentResult{treatment_results: treatment_results}
    Lab.performed_experiment(lab, experiment_result)
    {:ok, experiment_results} = Lab.get_experiment_results(lab)
    assert [experiment_result] == experiment_results
  end
end
