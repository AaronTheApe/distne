defmodule Distne.Net.Utils do
  @moduledoc """
  Utils is a collection of functions with common utility to to Net nodes
  """
  @doc """
  Stimulates an Con, Hid, In, or Out, with PID `pid`, by amount `amount`
  """
  def stim(pid, amount) do
    GenServer.call(pid, {:stim, amount})
  end
end
