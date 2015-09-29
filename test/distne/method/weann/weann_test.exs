defmodule Distne.Method.Weann.WeannTest do
  use ExUnit.Case

  alias Distne.Method.Weann.Weann, as: Weann

  test "Weann solves bit parity" do
    {:ok, weann} = Weann.start_link(%{})
    {:ok, client} = TestProbe.start_link
  end
end
