defmodule RungeKuttaTest do
  use ExUnit.Case

  alias Distne.Task.PoleBalancing.RungeKutta

  def change_in_ball_temp(_x, y, _constants) do
    -2.2067*:math.pow(10, -12)*(:math.pow(y, 4) - 81*:math.pow(10, 8))
  end

  test "solves http://w3.gazi.edu.tr/~balbasi/mws_gen_ode_txt_runge4th.pdf example 3" do
    {:ok, rk_pid} = RungeKutta.start_link(&change_in_ball_temp/3, 1200, 240, [])
    assert is_pid(rk_pid)
    assert {:ok, 675.6509511828407} = RungeKutta.step(rk_pid)
    assert {:ok, 594.912631110278} = RungeKutta.step(rk_pid)
  end

  defp sgn(x) do
    if x > 0 do
      1
    else
      if x < 0 do
        -1
      else
        0
      end
    end
  end

  #TODO
  # Simply Formulas
  # Make effective formulas composed in acceleration formulas
  # Make acceleration formulas take x, y, remaining variables in list
  # simulate poll with no force but initial angle wrong
  # watch it dance

  defp eff_pm(m, angle) do
    cos_angle = :math.cos(angle)
    cos_angle_squared = cos_angle*cos_angle
    m * (1 - 3 / 4 * cos_angle_squared)
  end

  defp eff_pf(m, l, velocity, angle, hinge_friction_coeff, gravity) do
    term1 = mass*length*velocity*velocity*:math.sin(angle)
    term2 = 3/4*mass*:math.cos(angle)*((hinge_friction_coeff*velocity)/(mass*length) + gravity*:math.sin(angle))
    term1 + term2
  end

  defp x_accelleration(task_force, track_friction_coeff, x_velocity, eff_pole_force, cart_mass, eff_pole_mass) do
    (task_force - cart_mass * sgn(x) + eff_pole_force)/(cart_mass + eff_pole_mass)
  end

  defp angular_acceleration(length, x_acc, angle, gravity, hinge_friction_coeff, velocity, pole_mass) do
    (3 / (4*length))*(x_acc*:math.cos(angle) + gravity*:math.sin(angle) + (hinge_friction_coeff*velocity)/(pole_mass*length))
  end

  test "solves http://machinelearning.wustl.edu/mlpapers/paper_files/gomez08a.pdf single pole" do
    
  end
end
