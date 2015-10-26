defmodule Distne.Task.PoleBalancing.SinglePole do
  use GenServer

  defmodule State do
    
  end

  alias Distne.Task.PoleBalancing.SinglePole

  def start_link do

  end

  def step(pid, force) do
    GenServer.call(pid, {:step, force})
  end

  def handle_call({:step, force}, _sender, state) do
    
    new_state = %State{:state| x_pos: x_pos, x_vel: x_vel, angle: angle, angular_vel: angular_vel}
    {:reply, {:ok, x_pos, x_vel, angle, angular_vel}, new_state}
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

  defp effective_pole_mass(pole_mass, angle) do
    cos_angle = :math.cos(angle)
    cos_angle_squared = cos_angle*cos_angle
    pole_mass * (1 - 3 / 4 * cos_angle_squared)
  end

  defp effective_pole_force(mass, length, velocity, angle, hinge_friction_coeff, gravity) do
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
end
