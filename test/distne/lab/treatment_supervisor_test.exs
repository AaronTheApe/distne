defmodule Distne.Lab.TreatmentSupevisorTest do
  use ExUnit.Case

  alias Distne.Lab.Tech, as: Tech
  alias Distne.Lab.Treatment, as: Treatment
  alias Distne.Lab.Task, as: Task
  alias Distne.Lab.Experiment, as: Experiment
  alias Distne.Lab.TreatmentResult, as: TreatmentResult
  alias Distne.Net.TestProbe, as: TestProbe

  test "TreatmentSupervisor starts with a tech, and creates a element_supervisor" do
    # {:ok, tech} = TestProbe.start_link
    # {:ok, treatment_supervisor} = TreatmentSupervisor.start_link(tech)
    # {:ok, treatment_supervisor} = Tech.get_treatment_supervisor(tech)
    # assert is_pid treatment_supervisor
  end

  # test "A Tech begins an experiment by delegating the first treatment to its treatment_evaluator" do
  #   {:ok, lab} = TestProbe.start_link
  #   {:ok, tech} = Tech.start_link(lab)
  #   {:ok, treatment_supervisor} = TestProbe.start_link
  #   :ok = Tech.set_treatment_supervisor(tech, treatment_supervisor)
  #   name = "rwg_vs_weann"
  #   treatments = [
  #     %Treatment{name: "rwg", method: :rwg, settings: %{num_inputs: 2}},
  #     %Treatment{name: "weann", method: :weann, settings: %{num_inputs: 3}}
  #   ]
  #   task = %Task{name: :bit_parity, settings: %{bits: 3}, num_trials: 10}
  #   sample_size = 50
  #   experiment = %Experiment{
  #     name: name, treatments: treatments, task: task, sample_size: sample_size}
  #   Tech.perform_experiment(tech, experiment)
  #   {:ok, actual_experiment} = Tech.get_experiment(tech)
  #   assert experiment == actual_experiment
  #   [first_treatment|rest] = experiment.treatments
  #   TestProbe.assert_receive(treatment_supervisor, {:perform_treatment, first_treatment}, 100)
  #   assert {:ok, rest} == Tech.get_remaining_treatments(tech)
  # end
  #
  # test "On completion of a treatment, treatment_result is added to treatment_results, and next treatment is delegated" do
  # end
end
