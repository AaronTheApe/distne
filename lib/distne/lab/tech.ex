defmodule Distne.Lab.Tech do
  use GenServer

  defmodule State do
    defstruct lab: nil
  end

  alias Distne.Lab.Tech, as: Tech

  #API
  def start_link(lab) do
    GenServer.start_link(Tech, %State{lab: lab})
  end

  def perform_experiment(tech, experiment) do
    GenServer.cast(tech, {:perform_experiment, experiment})
  end

  #GenServer Callbacks
end
