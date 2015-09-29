defmodule Distne.Method.Weann.WeannTest do
  use ExUnit.Case

  alias Distne.Method.Weann.Weann, as: Weann
  alias Distne.Method.Weann.WeannSettings, as: WeannSettings
  alias Distne.Net.TestProbe, as: TestProbe
  alias Distne.Task.Task, as: Task

  test "Weann solves bit parity" do
    weann_settings = %WeannSettings{num_inputs: 3, num_hidden: 5, num_outputs: 1, min_weight: -10.0, max_weight: 10.0, mut_rate: 0.10, mut_std_dev: 10.0, pop_size: 50}
    {:ok, weann} = Weann.start_link(weann_settings)
    {:ok, client} = TestProbe.start_link

    task_settings = %{size: 2}
    task = %Task{name: :bit_parity, settings: task_settings, num_trials: 10, fitness: 0.99}

    Weann.solve(weann, task, client)

    wait_for_solution(client)
  end

  def wait_for_solution(client) do
    {status, fitness, id} = TestProbe.received(client, 10000)
    IO.puts "status: #{status}"
    IO.puts "#{fitness}"
    IO.puts "id: #{id}"
    IO.puts "processes: #{length(:erlang.processes)}"
    if status == :not_solved do
      wait_for_solution(client)
    end
  end
end
