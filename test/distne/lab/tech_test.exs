defmodule Distne.Lab.TechTest do
  use ExUnit.Case

  alias Distne.Lab.Tech, as: Tech
  alias Distne.Lab.Treatment, as: Treatment
  alias Distne.Lab.Task, as: Task
  alias Distne.Lab.Experiment, as: Experiment
  alias Distne.Lab.TreatmentResult, as: TreatmentResult
  alias Distne.Net.TestProbe, as: TestProbe
  alias Distne.Lab.ExperimentResult, as: ExperimentResult

  test "Tech starts with a lab, and creates a treatment_supervisor" do
    {:ok, lab} = TestProbe.start_link
    {:ok, tech} = Tech.start_link(lab)
    {:ok, treatment_supervisor} = Tech.get_treatment_supervisor(tech)
    assert is_pid treatment_supervisor
  end

  test "A Tech begins an experiment by delegating the first treatment to its treatment_evaluator" do
    {:ok, lab} = TestProbe.start_link
    {:ok, tech} = Tech.start_link(lab)
    {:ok, treatment_supervisor} = TestProbe.start_link
    :ok = Tech.set_treatment_supervisor(tech, treatment_supervisor)
    name = "rwg_vs_weann"
    treatments = [
      %Treatment{name: "rwg", method: :rwg, settings: %{num_inputs: 2}},
      %Treatment{name: "weann", method: :weann, settings: %{num_inputs: 3}}
    ]
    task = %Task{name: :bit_parity, settings: %{bits: 3}, num_trials: 10}
    sample_size = 50
    experiment = %Experiment{
      name: name, treatments: treatments, task: task, sample_size: sample_size}
    Tech.perform_experiment(tech, experiment)
    {:ok, actual_experiment} = Tech.get_experiment(tech)
    assert experiment == actual_experiment
    [first_treatment|rest] = experiment.treatments
    TestProbe.assert_receive(treatment_supervisor, {:perform_treatment, first_treatment, experiment.task, experiment.sample_size}, 100)
    assert {:ok, rest} == Tech.get_remaining_treatments(tech)
    treatment_name = "rwg"
    cpu_time = 133.7
    generations = 78
    tasks = 523
    treatment_result =
      %TreatmentResult{
        treatment_name: treatment_name,
        cpu_time: cpu_time,
        generations: generations,
        tasks: tasks
      }
    Tech.performed_treatment(tech, treatment_result)
    [next_treatment|blah] = rest
    TestProbe.assert_receive(treatment_supervisor, {:perform_treatment, next_treatment, experiment.task, experiment.sample_size}, 100)
    Tech.performed_treatment(tech, treatment_result)
    TestProbe.assert_receive(lab, {:performed_experiment, %ExperimentResult{treatment_results: [treatment_result, treatment_result]}}, 100)
  end
end
