defmodule Distne.Task.BitParity.BitParity do
  require Integer

  def even(bits) do
    if Integer.is_even(Enum.count(bits, fn(bit) -> bit == 1 end)) do
      0
    else
      1
    end
  end

  def odd(bits) do
    if Integer.is_odd(Enum.count(bits, fn(bit) -> bit == 1 end)) do
      0
    else
      1
    end
  end
end
