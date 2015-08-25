#defmodule Distne.Experiment.ExperimentRunner do
  # use GenServer
  #
  # defmodule State do
  #   defstruct experiment: nil, experiment_design: nil
  # end
  #
  # alias Distne.Experiment.ExperimentRunner, as: ExperimentRunner
  # alias Distne.Experiment.ExperimentDesign, as: ExperimentDesign
  # alias Distne.Experiment.ExperimentResult, as: ExperimentResult
  # alias Distne.Experiment.TreatmentResult, as: TreatmentResult
  # alias Distne.Experiment.Experiment, as: Experiment
  #
  # def start_link(experiment_design) do
  #   GenServer.start_link(
  #     ExperimentRunner,
  #     %State{experiment_design: experiment_design})
  # end
  #
  # def run(experiment, experiment_runner) do
  #   GenServer.cast(experiment_runner, {:run, experiment})
  # end
  #
  # def handle_cast({:run, experiment}, state) do
  #   IO.puts "Running experiment #{state.experiment_design.name}"
  #   experiment_result = fake_result
  #   Experiment.conclude(experiment, fake_result)
  #   {:noreply, %State{state|experiment: experiment}}
  # end
  #
  # def fake_result do
  #   treatment_results = [
  #     %TreatmentResult{
  #       treatment_name: "rwg",
  #       cpu_time: 200.2,
  #       generations: 80,
  #       tasks: 300
  #     },
  #     treatment_result_2 =
  #       %TreatmentResult{
  #         treatment_name: "weann",
  #         cpu_time: 100.6,
  #         generations: 40,
  #         tasks: 127
  #       }
  #     ]
  #   %ExperimentResult{treatment_results: treatment_results}
  # end
#end
