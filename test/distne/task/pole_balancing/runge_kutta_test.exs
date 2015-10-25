defmodule RungeKuttaTest do
  use ExUnit.Case

  alias Distne.Task.PoleBalancing.RungeKutta

  def change_in_ball_temp(_x, y) do
    -2.2067*:math.pow(10, -12)*(:math.pow(y, 4) - 81*:math.pow(10, 8))
  end

  test "solves http://w3.gazi.edu.tr/~balbasi/mws_gen_ode_txt_runge4th.pdf example 3" do
    {:ok, rk_pid} = RungeKutta.start_link(&change_in_ball_temp/2, 1200, 240)
    assert is_pid(rk_pid)
    assert {:ok, 675.6509511828407} = RungeKutta.step(rk_pid)
    assert {:ok, 594.912631110278} = RungeKutta.step(rk_pid)
  end
end
