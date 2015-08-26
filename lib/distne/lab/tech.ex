defmodule Distne.Lab.Tech do
  use GenServer

  defmodule State do
    defstruct lab: nil, treatment_supervisor: nil, experiment: nil, remaining_treatments: nil, treatment_results: []
  end

  alias Distne.Lab.Tech, as: Tech
  alias Distne.Lab.TreatmentSupervisor, as: TreatmentSupervisor
  alias Distne.Lab.Lab, as: Lab
  alias Distne.Lab.ExperimentResult, as: ExperimentResult

  #API
  def start_link(lab) do
    GenServer.start_link(Tech, %State{lab: lab})
  end

  def get_treatment_supervisor(tech) do
    GenServer.call(tech, :get_treatment_supervisor)
  end

  def set_treatment_supervisor(tech, treatment_supervisor) do
    GenServer.call(tech, {:set_treatment_supervisor, treatment_supervisor})
  end

  def perform_experiment(tech, experiment) do
    GenServer.cast(tech, {:perform_experiment, experiment})
  end

  def get_experiment(tech) do
    GenServer.call(tech, :get_experiment)
  end

  def get_remaining_treatments(tech) do
    GenServer.call(tech, :get_remaining_treatments)
  end

  def performed_treatment(tech, treatment_result) do
    GenServer.cast(tech, {:performed_treatment, treatment_result})
  end

  #GenServer Callbacks
  def init(args) do
    {:ok, treatment_supervisor} = TreatmentSupervisor.start_link(self)
    {:ok, %State{args|treatment_supervisor: treatment_supervisor}}
  end

  def handle_call(:get_treatment_supervisor, _sender, state) do
    {:reply, {:ok, state.treatment_supervisor}, state}
  end

  def handle_call({:set_treatment_supervisor, treatment_supervisor}, _sender, state) do
    {:reply, :ok, %State{state|treatment_supervisor: treatment_supervisor}}
  end

  def handle_cast({:perform_experiment, experiment}, state) do
    IO.puts "[Tech] Performing experiment #{experiment.name}..."
    [first_treatment|remaining_treatments] = experiment.treatments
    TreatmentSupervisor.perform_treatment(state.treatment_supervisor, first_treatment, experiment.task, experiment.sample_size)
    {:noreply, %State{state|experiment: experiment, remaining_treatments: remaining_treatments}}
  end

  def handle_call(:get_experiment, _sender, state) do
    {:reply, {:ok, state.experiment}, state}
  end

  def handle_call(:get_remaining_treatments, _sender, state) do
    {:reply, {:ok, state.remaining_treatments}, state}
  end

  def handle_cast({:performed_treatment, treatment_result}, state) do
    if state.remaining_treatments != [] do
      [next_treatment|remaining_treatments] = state.remaining_treatments
      TreatmentSupervisor.perform_treatment(state.treatment_supervisor, next_treatment, state.experiment.task, state.experiment.sample_size)
      {:noreply, %State{state|remaining_treatments: remaining_treatments, treatment_results: [treatment_result|state.treatment_results]}}
    else

      Lab.performed_experiment(state.lab, %ExperimentResult{treatment_results: [treatment_result|state.treatment_results]})
      {:noreply, state}
    end
  end
end
