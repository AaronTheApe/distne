defmodule Distne.Method.Weann.Weann do
  use GenServer

  # defmodule State do
  #   defstruct num_inputs: nil, num_hidden: nil, num_outputs: nil, min: -10, max: +10, size: nil
  # end

  # alias Distne.Method.Weann.Weann, as: Weann
  # alias Distne.Net.Net, as: Net
  # alias Distne.Task.Evaluator, as: Evaluator

  # def start_link(settings) do
  #   GenServer.start_link(
  #     Rwg,
  #     %State{num_inputs: settings.num_inputs, num_hidden: settings.num_hidden, num_outputs: settings.num_outputs, size: settings.size})
  # end

  # def solve(pid, task, client) do
  #   GenServer.cast(pid, {:solve, task, client})
  # end

  # def handle_cast({:solve, task, client}, state) do
  #   population = Enum.map(1..state.size, fn(_) ->
  #     random_genome(state)
  #   end)
  #   net = random_net(state)
  #   {:ok, evaluator} = Evaluator.start_link(self)
  #   Evaluator.evaluate(evaluator, net, task)
  #   {:noreply, %State{state|evaluator: evaluator, task: task, net: net, client: client}}
  # end

  # def handle_cast({:evaluated, net, fitness}, state) do
  #   generations = state.generations + 1
  #   tasks = state.tasks + 1
  #   if fitness >= state.task.fitness do
  #     Evaluator.stop(state.evaluator)
  #     GenServer.cast(state.client, {:solved, net, fitness, generations, tasks})
  #     {:noreply, state}
  #   else
  #     Net.stop(state.net)
  #     net = random_net(state)
  #     Evaluator.evaluate(state.evaluator, net, state.task)
  #     {:noreply, %State{state|net: net, generations: generations, tasks: tasksg}}
  #   end
  # end

  # def random_net(state) do
  #   {:ok, net} = Net.start_link
  #   inputs = Enum.map(1..state.num_inputs,
  #     fn(_) ->
  #       {:ok, input} = Net.add_in(net)
  #       input
  #     end)
  #   hidden = Enum.map(1..state.num_hidden,
  #     fn(_) ->
  #       {:ok, hid} = Net.add_hid(net)
  #       hid
  #     end)
  #   outputs = Enum.map(1..state.num_outputs,
  #     fn(_) ->
  #       {:ok, output} = Net.add_out(net)
  #       output
  #     end)
  #   Enum.each(inputs,
  #     fn(input) ->
  #       Enum.each(hidden,
  #         fn(hid) ->
  #           Net.connect(net, input, hid, random_weight(state))
  #         end
  #       )
  #     end)
  #   Enum.each(hidden,
  #     fn(hid) ->
  #       Enum.each(outputs,
  #         fn(output) ->
  #           Net.connect(net, hid, output, random_weight(state))
  #         end
  #       )
  #     end)
  #   net
  # end

  # def random_weight(state) do
  #   range = state.max - state.min
  #   state.min + (:rand.uniform * range)
  # end
end
