defprotocol Distne.Net.Stimable do
  @fallback_to_any true
  defdelegate stim(pid, amount), to: Distne.Net.Utils
end
