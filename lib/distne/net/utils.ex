defmodule Distne.Net.Utils do
  def stim(pid, amount) do
    GenServer.call(pid, {:stim, amount})
  end
end
