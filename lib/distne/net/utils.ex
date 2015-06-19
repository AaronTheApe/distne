defmodule Distne.Net.Utils do
  @moduledoc """
  Utils is a collection of functions with common utility to to Net nodes
  """
  def stim(pid, amount) do
    GenServer.call(pid, {:stim, amount})
  end
end
