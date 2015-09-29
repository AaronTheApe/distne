defmodule Distne.Method.Weann.WeannTest do
  use ExUnit.Case

  alias Distne.Method.Weann.Weann, as: Weann
  alias Distne.Method.Weann.WeannSettings, as: WeannSettings
  alias Distne.Net.TestProbe, as: TestProbe
  alias Distne.Task.Task, as: Task

  @tag timeout: 300000
  test "Weann solves bit parity" do
    weann_settings = %WeannSettings{num_inputs: 4, num_hidden: 4, num_outputs: 1, min_weight: -10.0, max_weight: 10.0, mut_rate: 0.10, mut_std_dev: 10.0, pop_size: 100}
    {:ok, weann} = Weann.start_link(weann_settings)
    {:ok, client} = TestProbe.start_link

    task_settings = %{size: 3}
    task = %Task{name: :bit_parity, settings: task_settings, num_trials: 100, fitness: 0.95}

    Weann.solve(weann, task, client)

    IO.puts "generation, status, fitness, tasks, id, processes"
    wait_for_solution(client)
  end

  def wait_for_solution(client) do
    {status, generations, tasks, fitness, id} = TestProbe.received(client, 10000)
    IO.puts "#{generations}, #{status}, #{fitness}, #{tasks}, #{id}, #{length(:erlang.processes)}"
    if status == :not_solved do
      wait_for_solution(client)
    end
  end
end
