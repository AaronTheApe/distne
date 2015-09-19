defmodule Distne.Lab.Lab do
  use GenServer

  defmodule State do
    defstruct tech: nil, experiment_results: []
  end

  alias Distne.Lab.Lab, as: Lab
  alias Distne.Lab.Tech, as: Tech
  alias Distne.Lab.ExperimentResult, as: ExperimentResult

  #API
  def start_link do
    GenServer.start_link(Lab, nil)
  end

  def set_tech(lab, tech) do
    GenServer.call(lab, {:set_tech, tech})
  end

  def get_tech(lab) do
    GenServer.call(lab, :get_tech)
  end

  def perform_experiment(lab, experiment) do
    GenServer.cast(lab, {:perform_experiment, experiment})
  end

  def performed_experiment(lab, experiment_result) do
    GenServer.cast(lab, {:performed_experiment, experiment_result})
  end

  def get_experiment_results(lab) do
    GenServer.call(lab, :get_experiment_results)
  end

  #GenServer Callbacks
  def init(_args) do
    IO.puts "Constructing Lab..."
    {:ok, tech} = Tech.start_link(self)
    {:ok, %State{tech: tech}}
  end

  def handle_call({:set_tech, tech}, _sender, state) do
    {:reply, :ok, %State{state|tech: tech}}
  end

  def handle_call(:get_tech, _sender, state) do
    {:reply, {:ok, state.tech}, state}
  end

  def handle_call(:get_experiment_results, _sender, state) do
    {:reply, {:ok, state.experiment_results}, state}
  end

  def handle_cast({:perform_experiment, experiment}, state) do
    IO.puts "Performing experiment #{experiment.name}..."
    Tech.perform_experiment(state.tech, experiment)
    {:noreply, state}
  end

  def handle_cast({:performed_experiment, experiment_result}, state) do
    ExperimentResult.puts(experiment_result)
    {:noreply, %State{state|experiment_results:
      [experiment_result|state.experiment_results]}}
  end
end
