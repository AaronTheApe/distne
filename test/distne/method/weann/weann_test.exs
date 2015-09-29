defmodule Distne.Method.Weann.WeannTest do
  use ExUnit.Case

  alias Distne.Method.Weann.Weann, as: Weann
  alias Distne.Method.Weann.WeannSettings, as: WeannSettings
  alias Distne.Net.TestProbe, as: TestProbe

  test "Weann solves bit parity" do
    settings = %WeannSettings{num_inputs: 3, num_hidden: 5, num_outputs: 1}
    {:ok, weann} = Weann.start_link(settings)
    {:ok, client} = TestProbe.start_link
    
  end
end
