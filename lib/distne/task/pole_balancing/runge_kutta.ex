defmodule Distne.Task.PoleBalancing.RungeKutta do
  use GenServer

  defmodule State do
    defstruct dydx: nil, y0: nil, h: nil, xi: nil, yi: nil
  end

  alias Distne.Task.PoleBalancing.RungeKutta

  def start_link(dydx, y0, h) do
    GenServer.start_link(RungeKutta, %State{dydx: dydx, y0: y0, h: h, xi: 0, yi: y0})
  end

  def step(pid) do
    GenServer.call(pid, :step)
  end

  def handle_call(:step, _sender, state) do
    kone = k1(state.dydx, state.xi, state.yi)
    ktwo = k2(state.dydx, state.xi, state.yi, state.h)
    kthree = k3(state.dydx, state.xi, state.yi, state.h)
    kfour = k4(state.dydx, state.xi, state.yi, state.h)
    yi = state.yi + (1.0/6.0)*(kone + 2*ktwo + 2*kthree + kfour)*state.h
    xi = state.xi + state.h
    {:reply, {:ok, yi}, %State{state| xi: xi, yi: yi}}
  end

  defp k1(dydx, xi, yi) do
    dydx.(xi, yi)
  end

  defp k2(dydx, xi, yi, h) do
    dydx.(xi + 0.5*h, yi + 0.5*k1(dydx, xi, yi)*h)
  end

  defp k3(dydx, xi, yi, h) do
    dydx.(xi + 0.5*h, yi + 0.5*k2(dydx, xi, yi, h)*h)
  end

  defp k4(dydx, xi, yi, h) do
    dydx.(xi + h, yi + k3(dydx, xi, yi, h)*h)
  end
end
