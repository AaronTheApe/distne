defmodule Distne.Task.BitParity.BitParityNeuroController do
  use GenServer

  require Record
  Record.defrecordp :state, net: nil, task: nil

  alias Distne.Task.BitParity.BitParityTask, as: BitParityTask
  alias Distne.Task.BitParity.BitParityNeuroController, as: BitParityNeuroController

  def start_link(net, task) do
    GenServer.start_link(BitParityNeuroController, state(net: net, task: task))
  end

  def bits(nc, bits) do
    GenServer.cast(nc, {:bits, bits})
  end

  def output_vector(nc, output_vector) do
    GenServer.cast(nc, {:output_vector, output_vector})
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_cast({:bits, bits}, state) do
    #IO.inspect bits
    bias = 1.0
    GenServer.cast(state(state, :net), {:input_vector, [bias |
      Enum.map(bits, fn(b) ->
        if b == 0 do
          0.1
        else
          0.9
        end
      end)
    ]})
    {:noreply, state}
  end

  def handle_cast({:output_vector, [output]}, state) do
    #IO.inspect(output)
    # parity =
    #   if output > 0.0 do
    #     1
    #   else
    #     0
    #   end
    BitParityTask.parity(state(state, :task), output)
    {:noreply, state}
  end
end
