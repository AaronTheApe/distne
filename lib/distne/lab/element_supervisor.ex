defmodule Distne.Lab.ElementSupervisor do
  use GenServer

  defmodule State do
    defstruct treatment_supervisor: nil
  end

  alias Distne.Lab.ElementSupervisor, as: ElementSupervisor
  alias Distne.Method.Rwg.Rwg, as: Rwg

  def start_link(treatment_supervisor) do
    GenServer.start_link(ElementSupervisor, %State{treatment_supervisor: treatment_supervisor})
  end

  def perform_element(element_supervisor, treatment, task) do
    GenServer.cast(element_supervisor, {:perform_element, treatment, task})
  end

  def handle_cast({:perform_element, treatment, task}, state) do
    if treatment.method == :rwg do
      {:ok, rwg} = Rwg.start_link(treatment.settings)
      Rwg.solve(rwg, task)
    end
    {:noreply, state}
  end
end
