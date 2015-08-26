defmodule Distne.Lab.TreatmentSupervisor do
  use GenServer

  defmodule State do
    defstruct blah: nil
  end

  alias Distne.Lab.TreatmentSupervisor, as: TreatmentSupervisor

  def start_link do
    GenServer.start_link(TreatmentSupervisor, nil)
  end

  def perform_treatment(treatment_supervisor, treatment) do
    GenServer.cast(treatment_supervisor, {:perform_treatment, treatment})
  end
end
