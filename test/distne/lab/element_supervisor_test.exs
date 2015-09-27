defmodule Distne.Lab.ElementSupevisorTest do
  use ExUnit.Case

  alias Distne.Net.TestProbe, as: TestProbe
  alias Distne.Lab.ElementSupervisor, as: ElementSupervisor
  alias Distne.Lab.Treatment, as: Treatment
  alias Distne.Task.Task, as: Task

  test "An ElementSupervisor supervises elements" do
    {:ok, treatment_supervisor} = TestProbe.start_link
    {:ok, element_supervisor} = ElementSupervisor.start_link(treatment_supervisor)
    treatment = %Treatment{name: "rwg", method: :rwg, settings: %{num_inputs: 3, num_hidden: 3, num_outputs: 1}}
    task = %Task{name: :bit_parity, settings: %{bits: 2}, num_trials: 10}
    ElementSupervisor.perform_element(element_supervisor, treatment, task)
    blah = TestProbe.received(treatment_supervisor, 100)
    IO.inspect(blah)
  end
end
