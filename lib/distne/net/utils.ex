defmodule Distne.Net.Utils do
  @moduledoc """
  Utils is a collection of functions with common utility to to Net nodes
  """
  @doc """
  Stimulate a Net node identified by pid by amount
  """
  def stim(pid, amount) do
    GenServer.call(pid, {:stim, amount})
  end
end
