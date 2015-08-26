defmodule Distne.Net.Net do
  @moduledoc """
  A Net acts as an artificial neural network
  """
  use GenServer

  require Record
  Record.defrecordp :state, sensory_array: nil, ins: [], hids: HashSet.new, outs: [], cons: HashSet.new, pending: [], received: %{}, actuator_array: nil, sensor_array: nil

  alias Distne.Net.Net, as: Net
  alias Distne.Net.In, as: In
  alias Distne.Net.Hid, as: Hid
  alias Distne.Net.Out, as: Out
  alias Distne.Net.Con, as: Con

  @doc """
    Adds a new Hid to Net with PID `net`, and returns
    the new Hid's PID
  """
  def add_hid(net) do
    GenServer.call(net, :add_hid)
  end

  @doc """
    Adds a new In to the Net with PID `net`, and returns
    this new In's PID
  """
  def add_in(net) do
    GenServer.call(net, :add_in)
  end

  @doc """
    Adds a new Out to the Net with PID `net`, and returns
    this new Out's PID
  """
  def add_out(net) do
    GenServer.call(net, :add_out)
  end

  @doc """
    Connects `net`'s' `source` to `sink` with `weight`
  """
  def connect(net, source, sink, weight) do
    GenServer.call(net, {:connect, source, sink, weight})
  end

  @doc """
    Stimulates `net` with input vector `v`
  """
  def input_vector(net, v) do
    GenServer.cast(net, {:input_vector, v})
  end

  @doc """
    Sets 'net's 'actuator_array'
  """
  def set_actuator_array(net, actuator_array) do
    :ok = GenServer.call(net, {:set_actuator_array, actuator_array})
  end

  @doc """
    Sets 'net's 'sensor_array'
  """
  def set_sensor_array(net, sensor_array) do
    :ok = GenServer.call(net, {:set_sensor_array, sensor_array})
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

  def handle_cast({:input_vector, v}, state) do
    zip = Enum.zip(state(state, :ins), v)
    Enum.each(zip, fn {i, iv} ->
      GenServer.cast(i, {:stim, self(), iv})
    end)
    {:noreply, state}
  end

  def handle_call({:set_actuator_array, actuator_array}, _from, state) do
    {:reply, :ok, state(state, actuator_array: actuator_array)}
  end

  def handle_call({:set_sensor_array, sensor_array}, _from, state) do
    {:reply, :ok, state(state, sensor_array: sensor_array)}
  end

  def handle_cast({:stim, from, amount}, state) do
    cur_pending = state(state, :pending)
    new_pending = List.delete(cur_pending, from)
    new_received = Map.put(state(state, :received), from, amount)
    if new_pending == [] do
      output_vector = Enum.map(state(state, :outs), fn(out) ->
        new_received[out]
      end)
      GenServer.cast(state(state, :actuator_array), {:output_vector, output_vector})
      {:noreply, state(state, pending: state(state, :outs), received: %{})}
    else
      {:noreply, state(state, pending: new_pending, received: new_received)}
    end
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end
end
