defprotocol Distne.Net.Stimable do
  @moduledoc """
  A Stimable is the protocol for any Net node that can receive a stim message
  """
  @fallback_to_any true
  @doc """
  Stimulates the Stimable pid by amount
  """
  defdelegate stim(pid, amount), to: Distne.Net.Utils
end
