defmodule Distne.Task.EvaluatorTest do
  use ExUnit.Case

  alias Distne.Task.Evaluator, as: Evaluator
  alias Distne.Task.Task, as: Task
  alias Distne.Net.TestProbe, as: TestProbe
  alias Distne.Method.Rwg.Rwg, as: Rwg

  test "An Evaluator can evaluate x trials of BitParity" do
    {:ok, method} = TestProbe.start_link
    {:ok, evaluator} = Evaluator.start_link(method)
    settings = %{size: 2}
    task = %Task{name: :bit_parity, settings: settings, num_trials: 10}
    net = Rwg.random_net(%{num_inputs: 3, num_hidden: 3, num_outputs: 1, min: -10, max: 10})
    Evaluator.evaluate(evaluator, net, task)
  end
end
