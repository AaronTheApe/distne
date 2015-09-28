defmodule Distne.Lab.ElementSupervisor do
  use GenServer

  defmodule State do
    defstruct treatment_supervisor: nil, solve_start: nil
  end

  alias Distne.Lab.ElementSupervisor, as: ElementSupervisor
  alias Distne.Lab.ElementResult, as: ElementResult
  alias Distne.Method.Rwg.Rwg, as: Rwg

  def start_link(treatment_supervisor) do
    GenServer.start_link(ElementSupervisor, %State{treatment_supervisor: treatment_supervisor})
  end

  def perform_element(element_supervisor, treatment, task) do
    GenServer.cast(element_supervisor, {:perform_element, treatment, task})
  end

  def handle_cast({:perform_element, treatment, task}, state) do
    solve_start = :erlang.monotonic_time
    if treatment.method == :rwg do
      IO.puts "blahblah"
      {:ok, rwg} = Rwg.start_link(treatment.settings)
      Rwg.solve(rwg, task, self)
    end
    {:noreply, %{state|solve_start: solve_start}}
  end

  def handle_cast({:solved, net, fitness, generations, tasks}, state) do
    solve_end = :erlang.monotonic_time
    monotonic_cpu_time = solve_end - state.solve_start
    cpu_time = :erlang.convert_time_unit(monotonic_cpu_time, :native, :milli_seconds)
    element_result = %ElementResult{fitness: fitness, generations: generations, cpu_time: cpu_time, tasks: tasks}
    GenServer.cast(state.treatment_supervisor, {:performed_element, element_result})
    {:noreply, state}
  end
end
