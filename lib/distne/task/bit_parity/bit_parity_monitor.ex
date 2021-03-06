defmodule Distne.Task.BitParity.BitParityMonitor do
  use GenServer

  defmodule State do
    defstruct task: nil, nc: nil, net: nil, fit_mon: nil
  end

  alias Distne.Task.BitParity.BitParityTask, as: BitParityTask
  alias Distne.Task.BitParity.BitParityMonitor, as: BitParityMonitor
  alias Distne.Task.BitParity.BitParityNeuroController, as: BitParityNeuroController
  alias Distne.Net.Net, as: Net

  def start_link(settings, net, fit_mon) do
    {:ok, mon} = GenServer.start_link(BitParityMonitor, %State{net: net, fit_mon: fit_mon})
    GenServer.cast(mon, {:create_task, settings.size})
    {:ok, mon}
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def handle_cast({:create_task, size}, state) do
    {:ok, task} = BitParityTask.start_link(size, self)
    {:ok, nc} = BitParityNeuroController.start_link(state.net, task)
    Net.set_actuator_array(state.net, nc)
    BitParityTask.begin(task, nc)
    {:noreply, %State{state | task: task, nc: nc}}
  end

  def handle_cast({:success, error}, state) do
    fitness = 1.0 - error
    GenServer.cast(state.fit_mon, {:fitness, state.net, fitness})
    {:noreply, state}
  end

  def handle_call(:stop, _from, state) do
    BitParityTask.stop(state.task)
    BitParityNeuroController.stop(state.nc)
    {:stop, :normal, :ok, state}
  end
end
