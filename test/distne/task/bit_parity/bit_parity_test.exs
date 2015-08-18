defmodule Distne.Task.BitParity.BitParityTest do
  use ExUnit.Case

  alias Distne.Task.BitParity.BitParity, as: BitParity

  test "BitParity.even() returns 0 for even # of 1 bits, 1 otherwise" do
    assert 0 == BitParity.even([0,0,0,0,0,0,0])
    assert 1 == BitParity.even([1,0,1,0,0,0,1])
    assert 0 == BitParity.even([1,1,0,1,0,0,1])
    assert 1 == BitParity.even([1,1,1,1,1,1,1])
  end

  test "BitParity.odd() returns 1 for even # of 1 bits, 0 otherwise" do
    assert 1 == BitParity.odd([0,0,0,0,0,0,0])
    assert 0 == BitParity.odd([1,0,1,0,0,0,1])
    assert 1 == BitParity.odd([1,1,0,1,0,0,1])
    assert 0 == BitParity.odd([1,1,1,1,1,1,1])
  end
end
