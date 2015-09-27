defmodule Distne.Lab.TreatmentSupevisorTest do
  use ExUnit.Case

  alias Distne.Lab.Tech, as: Tech
  alias Distne.Lab.Treatment, as: Treatment
  alias Distne.Task.Task, as: Task
  alias Distne.Lab.Experiment, as: Experiment
  alias Distne.Lab.TreatmentResult, as: TreatmentResult
  alias Distne.Net.TestProbe, as: TestProbe
  alias Distne.Lab.TreatmentSupervisor, as: TreatmentSupervisor
  alias Distne.Lab.ElementResult, as: ElementResult

  test "TreatmentSupervisor starts with a tech, and creates a element_supervisor
  to perform sample_size remaining samples" do
    {:ok, tech} = TestProbe.start_link
    {:ok, treatment_supervisor} = TreatmentSupervisor.start_link(tech)
    {:ok, actual_element_supervisor} = TreatmentSupervisor.get_element_supervisor(treatment_supervisor)
    assert is_pid actual_element_supervisor
    {:ok, actual_remaining_elements} = TreatmentSupervisor.get_remaining_elements(treatment_supervisor)
    assert nil == actual_remaining_elements
    {:ok, []} = TreatmentSupervisor.get_element_results(treatment_supervisor)

    {:ok, element_supervisor} = TestProbe.start_link
    :ok = TreatmentSupervisor.set_element_supervisor(treatment_supervisor, element_supervisor)
    treatment = %Treatment{name: "rwg", method: :rwg, settings: %{num_inputs: 2}}
    task = %Task{name: :bit_parity, settings: %{bits: 3}, num_trials: 10}
    sample_size = 2
    TreatmentSupervisor.perform_treatment(treatment_supervisor, treatment, task, sample_size)

    TestProbe.assert_receive(element_supervisor, {:perform_element, treatment, task}, 100)
    assert {:ok, 1} == TreatmentSupervisor.get_remaining_elements(treatment_supervisor)

    element_result_1 = %ElementResult{generations: 4, cpu_time: 30.7, tasks: 21}
    {:ok, element_supervisor} = TestProbe.start_link
    :ok = TreatmentSupervisor.set_element_supervisor(treatment_supervisor, element_supervisor)
    TreatmentSupervisor.performed_element(treatment_supervisor, element_result_1)

    assert {:ok, [element_result_1]} == TreatmentSupervisor.get_element_results(treatment_supervisor)
    TestProbe.assert_receive(element_supervisor, {:perform_element, treatment, task}, 100)

    element_result_2 = %ElementResult{generations: 7, cpu_time: 130.2, tasks: 52}
    TreatmentSupervisor.performed_element(treatment_supervisor, element_result_2)

    expected_cpu_time = (element_result_1.cpu_time + element_result_2.cpu_time)/2.0
    expected_generations = (element_result_1.generations + element_result_2.generations)/2.0
    expected_tasks = (element_result_1.tasks + element_result_2.tasks)/2.0
    expected_treatment_result = %TreatmentResult{cpu_time: expected_cpu_time, generations: expected_generations, tasks: expected_tasks, treatment_name: "rwg"}
    TestProbe.assert_receive(tech, {:performed_treatment, expected_treatment_result}, 1000)
  end



  #decrements remaining samples
  #accumulates gens, times, tasks
  #sends average gens, times, tasks as treatment_result when remaining_samples 0

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
