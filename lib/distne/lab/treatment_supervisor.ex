defmodule Distne.Lab.TreatmentSupervisor do
  use GenServer

  defmodule State do
    defstruct tech: nil, element_supervisor: nil, treatment: nil, task: nil, remaining_elements: nil, element_results: []
  end

  alias Distne.Lab.TreatmentSupervisor, as: TreatmentSupervisor
  alias Distne.Lab.ElementSupervisor, as: ElementSupervisor
  alias Distne.Lab.Tech, as: Tech
  alias Distne.Lab.TreatmentResult, as: TreatmentResult

  def start_link(tech) do
    GenServer.start_link(TreatmentSupervisor, %State{tech: tech})
  end

  def perform_treatment(treatment_supervisor, treatment, task, sample_size) do
    GenServer.cast(treatment_supervisor, {:perform_treatment, treatment, task, sample_size})
  end

  def set_element_supervisor(treatment_supervisor, element_supervisor) do
    GenServer.call(treatment_supervisor, {:set_element_supervisor, element_supervisor})
  end

  def get_element_supervisor(treatment_supervisor) do
    GenServer.call(treatment_supervisor, :get_element_supervisor)
  end

  def get_remaining_elements(treatment_supervisor) do
    GenServer.call(treatment_supervisor, :get_remaining_elements)
  end

  def get_element_results(treatment_supervisor) do
    GenServer.call(treatment_supervisor, :get_element_results)
  end

  def performed_element(treatment_supervisor, element_result) do
    GenServer.cast(treatment_supervisor, {:performed_element, element_result})
  end

  #GenServer callbacks
  def init(args) do
    {:ok, element_supervisor} = ElementSupervisor.start_link(self)
    {:ok, %State{args|element_supervisor: element_supervisor}}
  end

  def handle_call(:get_element_supervisor, _sender, state) do
    {:reply, {:ok, state.element_supervisor}, state}
  end

  def handle_call(:get_remaining_elements, _sender, state) do
    {:reply, {:ok, state.remaining_elements}, state}
  end

  def handle_call({:set_element_supervisor, element_supervisor}, _sender, state) do
    {:reply, :ok, %State{state|element_supervisor: element_supervisor}}
  end

  def handle_call(:get_element_results, _sender, state) do
    {:reply, {:ok, state.element_results}, state}
  end

  def handle_cast({:perform_treatment, treatment, task, sample_size}, state) do
    IO.puts "[TreatmentSupervisor] performing treatment #{treatment.name}"
    remaining_elements = sample_size - 1
    ElementSupervisor.perform_element(state.element_supervisor, treatment, task)
    {:noreply, %State{state|treatment: treatment, task: task, remaining_elements: remaining_elements, element_results: []}}
  end

  def handle_cast({:performed_element, element_result}, state) do
    if state.remaining_elements == 0 do
      element_results = [element_result|state.element_results]
      count = Enum.count(element_results)
      cpu_time_sum = Enum.sum(Enum.map(element_results, fn(r) -> r.cpu_time end))*1.0
      cpu_time =  cpu_time_sum/count
      generations_sum = Enum.sum(Enum.map(element_results, fn(r) -> r.generations end))*1.0
      generations = generations_sum/count
      tasks = Enum.sum(Enum.map(element_results, fn(r) -> r.tasks end))*1.0/count
      Tech.performed_treatment(state.tech, %TreatmentResult{treatment_name: state.treatment.name, cpu_time: cpu_time, generations: generations, tasks: tasks})
      {:noreply, %State{state|element_results: element_results}}
    else
      remaining_elements = state.remaining_elements - 1
      ElementSupervisor.perform_element(state.element_supervisor, state.treatment, state.task)
      {:noreply, %State{state|element_results: [element_result|state.element_results], remaining_elements: remaining_elements}}
    end
  end
end
