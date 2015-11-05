defmodule Distne.Task.PoleBalancing.PoleBalancing do
  def emi(mi, ti) do
    mi*(1 - (3/4)*:math.pow(:math.cos(ti), 2))
  end

  def efi(mi, li, tpi, ti, mewpi, g) do
    mi*li*tpi*tpi*:math.sin(ti) + (3/4)*mi*:math.cos(ti)*((mewpi*tpi)/(mi*li)+g*:math.sin(ti))
  end

  def xpp(f, mewc, xp, poles) do
    (f - mewc*sgn(xp) + sum_efis(poles))/(m + sum_)
  end
end
