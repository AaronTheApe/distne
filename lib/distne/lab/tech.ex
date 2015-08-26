defmodule Distne.Lab.Tech do
  use GenServer

  defmodule State do
    defstruct lab: nil, treatment_supervisor: nil, experiment: nil, remaining_treatments: nil
  end

  alias Distne.Lab.Tech, as: Tech
  alias Distne.Lab.TreatmentSupervisor, as: TreatmentSupervisor

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

  #GenServer Callbacks
  def init(args) do
    {:ok, treatment_supervisor} = TreatmentSupervisor.start_link
    {:ok, %State{args|treatment_supervisor: treatment_supervisor}}
  end

  def handle_call(:get_treatment_supervisor, _sender, state) do
    {:reply, {:ok, state.treatment_supervisor}, state}
  end

  def handle_call({:set_treatment_supervisor, treatment_supervisor}, _sender, state) do
    {:reply, :ok, %State{state|treatment_supervisor: treatment_supervisor}}
  end

  def handle_cast({:perform_experiment, experiment}, state) do
    [first_treatment|remaining_treatments] = experiment.treatments
    TreatmentSupervisor.perform_treatment(state.treatment_supervisor, first_treatment)
    {:noreply, %State{state|experiment: experiment, remaining_treatments: remaining_treatments}}
  end

  def handle_call(:get_experiment, _sender, state) do
    {:reply, {:ok, state.experiment}, state}
  end

  def handle_call(:get_remaining_treatments, _sender, state) do
    {:reply, {:ok, state.remaining_treatments}, state}
  end
end
