defmodule Distne.Task.BitParity.BitParityMonitor do
  use GenServer

  defmodule State do
    defstruct task: nil, nc: nil, net: nil, fit_mon: nil
  end

  alias Distne.Task.BitParity.BitParityTask, as: BitParityTask
  alias Distne.Task.BitParity.BitParityMonitor, as: BitParityMonitor
  alias Distne.Task.BitParity.BitParityNeuroController, as: BitParityNeuroController

  def start_link(size, net, fit_mon) do
    {:ok, mon} = GenServer.start_link(BitParityMonitor, %State{net: net, fit_mon: fit_mon})
    GenServer.cast(mon, {:create_task, size})
    {:ok, mon}
  end

  def handle_cast({:create_task, size}, state) do
    {:ok, task} = BitParityTask.start_link(size, self)
    {:ok, nc} = BitParityNeuroController.start_link(state.net, task)
    BitParityTask.begin(task, nc)
    {:noreply, %State{state | task: task, nc: nc}}
  end

  def handle_cast({:success, success}, state) do
    fitness =
      if success do
        1.0
      else
        0.0
      end
    GenServer.cast(state.fit_mon, {:fitness, state.net, fitness})
    {:noreply, state}
  end
end
