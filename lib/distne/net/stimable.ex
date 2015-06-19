defprotocol Distne.Net.Stimable do
  @fallback_to_any true
  @doc """
  Stimulates the Stimable pid by amount
  """
  defdelegate stim(pid, amount), to: Distne.Net.Utils
end
