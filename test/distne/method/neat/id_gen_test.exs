defmodule Distne.Method.Neat.IdGenTest do
  use ExUnit.Case

  alias Distne.Method.Neat.IdGen, as: IdGen

  test "innov_num increments for unique cons, remains fixed for non-unique cons" do
    next_node_id = 5
    next_innov_num = 10
    {:ok, pid} = IdGen.start_link(next_node_id, next_innov_num)
    con_in = 2
    con_out = 3
    expected_innov_num = next_innov_num
    {:ok, innov_num} = IdGen.innov_num(pid, con_in, con_out)
    assert next_innov_num == innov_num
    con_2_in = 3
    con_2_out = 2
    {:ok, con_2_innov_num} = IdGen.innov_num(pid, con_2_in, con_2_out)
    assert innov_num != con_2_innov_num
    {:ok, con_2_2_innov_num} = IdGen.innov_num(pid, con_2_in, con_2_out)
    assert con_2_2_innov_num == con_2_innov_num
  end

  test "node_id increments for unique cons, remains fixed for non-unique cons" do
    next_node_id = 5
    next_innov_num = 10
    {:ok, pid} = IdGen.start_link(next_node_id, next_innov_num)
    con_in = 2
    con_out = 3
    expected_node_id = next_node_id
    {:ok, node_id} = IdGen.node_id(pid, con_in, con_out)
    assert next_node_id == node_id
    con_2_in = 3
    con_2_out = 2
    {:ok, con_2_node_id} = IdGen.node_id(pid, con_2_in, con_2_out)
    assert node_id != con_2_node_id
    {:ok, con_2_2_node_id} = IdGen.node_id(pid, con_2_in, con_2_out)
    assert con_2_2_node_id == con_2_node_id
  end
end
