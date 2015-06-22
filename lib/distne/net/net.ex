defmodule Distne.Net.Net do
  use GenServer

  require Record
  Record.defrecordp :state, sensory_array: nil, ins: [], hids: HashSet.new, outs: [], cons: HashSet.new, pending: [], received: %{}, actuator_array: nil

  alias Distne.Net.Net, as: Net
  alias Distne.Net.In, as: In
  alias Distne.Net.Hid, as: Hid
  alias Distne.Net.Out, as: Out
  alias Distne.Net.Con, as: Con

  def add_hid(net) do
    GenServer.call(net, :add_hid)
  end

  def add_in(net) do
    GenServer.call(net, :add_in)
  end

  def add_out(net) do
    GenServer.call(net, :add_out)
  end

  def connect(net, source, sink, weight) do
    GenServer.call(net, {:connect, source, sink, weight})
  end

  def input_vector(net, v) do
    GenServer.call(net, {:input_vector, v})
  end

  def set_actuator_array(net, actuator_array) do
    GenServer.call(net, {:set_actuator_array, actuator_array})
  end

  def set_sensor_array(net, sensor_array) do
    :ok
  end

  def start_link() do
    GenServer.start_link(Net, state())
  end

  def handle_call(:add_hid, _from, state) do
    {:ok, hid} = Hid.start_link()
    {:reply, {:ok, hid}, state(state, hids: Set.put(state(state, :hids), hid))}
  end

  def handle_call(:add_in, _from, state) do
    {:ok, i} = In.start_link()
    {:reply, {:ok, i}, state(state, ins: [i | state(state, :ins)])}
  end

  def handle_call(:add_out, _from, state) do
    {:ok, out} = Out.start_link()
    Out.set_sink(out, self())
    {:reply, {:ok, out}, state(state, outs: [out | state(state, :outs)], pending: [out | state(state, :pending)])}
  end

  def handle_call({:connect, source, sink, weight}, _from, state) do
    {:ok, con} = Con.start_link(weight)
    Con.set_source(con, source)
    GenServer.call(source, {:add_sink, con})
    Con.set_sink(con, sink)
    GenServer.call(sink, {:add_source, con})
    {:reply, {:ok, con}, state(state, cons: Set.put(state(state, :cons), con))}
  end

  def handle_call({:input_vector, v}, _from, state) do
    zip = Enum.zip(state(state, :ins), v)
    Enum.each(zip, fn {i, iv} ->
      GenServer.cast(i, {:stim, self(), iv})
    end)
    {:reply, :ok, state}
  end

  def handle_call({:set_actuator_array, actuator_array}, _from, state) do
    {:reply, :ok, state(state, actuator_array: actuator_array)}
  end

  def handle_cast({:stim, from, amount}, state) do
    cur_pending = state(state, :pending)
    new_pending = List.delete(cur_pending, from)
    new_received = Map.put(state(state, :received), from, amount)
    if new_pending == [] do
      output_vector = Enum.map(state(state, :outs), fn(out) ->
        new_received[out]
      end)
      GenServer.call(state(state, :actuator_array), {:output_vector, output_vector})
      {:noreply, state(state, pending: state(state, :outs), received: %{})}
    else
      {:noreply, state(state, pending: new_pending, received: new_received)}
    end
  end
end
