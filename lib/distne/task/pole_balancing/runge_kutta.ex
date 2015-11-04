defmodule Distne.Task.PoleBalancing.RungeKutta do
  use GenServer

  defmodule State do
    defstruct dydx: nil, y0: nil, h: nil, xi: nil, yi: nil, constants: nil
  end

  alias Distne.Task.PoleBalancing.RungeKutta

  def start_link(dydx, y0, h, constants) do
    GenServer.start_link(RungeKutta, %State{dydx: dydx, y0: y0, h: h, xi: 0, yi: y0, constants: constants})
  end

  def step(pid) do
    GenServer.call(pid, :step)
  end

  def handle_call(:step, _sender, state) do
    kone = k1(state.dydx, state.xi, state.yi, state.constants)
    ktwo = k2(state.dydx, state.xi, state.yi, state.h, state.constants)
    kthree = k3(state.dydx, state.xi, state.yi, state.h, state.constants)
    kfour = k4(state.dydx, state.xi, state.yi, state.h, state.constants)
    yi = state.yi + (1.0/6.0)*(kone + 2*ktwo + 2*kthree + kfour)*state.h
    xi = state.xi + state.h
    {:reply, {:ok, yi}, %State{state| xi: xi, yi: yi}}
  end

  defp k1(dydx, xi, yi, constants) do
    apply(dydx, [xi, yi, constants])
  end

  defp k2(dydx, xi, yi, h, constants) do
    apply(dydx, [xi + 0.5*h, yi + 0.5*k1(dydx, xi, yi, constants)*h, constants])
  end

  defp k3(dydx, xi, yi, h, constants) do
    apply(dydx, [xi + 0.5*h, yi + 0.5*k2(dydx, xi, yi, h, constants)*h, constants])
  end

  defp k4(dydx, xi, yi, h, constants) do
    apply(dydx, [xi + h, yi + k3(dydx, xi, yi, h, constants)*h, constants])
  end
end
