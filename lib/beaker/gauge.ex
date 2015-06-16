defmodule Beaker.Gauge do
  @moduledoc """
  `Beaker.Gauge` is a simple gauge. It's a metric where a value can be set and retrieved.

  It is commonly used for metrics that return a single value.

  Examples are:
    * Average response time
    * Uptime (Availability)
    * Latency / Ping

  """

  ## Client API

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :beaker_gauges)
  end

  @doc """
  Retrieves all gauges in the form of a map.

  ## Examples

      iex> Beaker.Gauge.clear
      :ok
      iex> Beaker.Gauge.set("all_gauge1", 10)
      :ok
      iex> Beaker.Gauge.set("all_gauge2", 1)
      :ok
      iex> Beaker.Gauge.all
      %{"all_gauge1" => 10, "all_gauge2" => 1}

  Returns `gauges` where gauges is a map of all the gauges currently existing.
  """
  def all do
    GenServer.call(:beaker_gauges, :all)
  end


  @doc """
  Clears all gauges stored in Beaker.

  ## Examples

      iex> Beaker.Gauge.clear
      :ok
      iex> Beaker.Gauge.set("all_gauge1", 10)
      :ok
      iex> Beaker.Gauge.set("all_gauge2", 1)
      :ok
      iex> Beaker.Gauge.all
      %{"all_gauge1" => 10, "all_gauge2" => 1}
      iex> Beaker.Gauge.clear
      :ok
      iex> Beaker.Gauge.all
      %{}

  Returns `:ok`.
  """
  def clear do
    GenServer.cast(:beaker_gauges, :clear)
  end

  @doc """
  Retrieves the current value of the specified gauge.

  ## Parameters
    * `key`: The name of the gauge to retrieve.

  ## Examples

      iex> Beaker.Gauge.set("get_gauge", 50)
      :ok
      iex> Beaker.Gauge.get("get_gauge")
      50

  Returns `count` where count is an integer if the gauge exists, else `nil`.
  """
  def get(key) do
    GenServer.call(:beaker_gauges, {:get, key})
  end

  @doc """
  Sets the gauge to the specified value.

  ## Parameters
    * `key`: The name of the gauge to set the value for.
    * `value`: The value to set to the gauge.

  ## Examples

      iex> Beaker.Gauge.set("set_gauge", 3.14159)
      :ok
      iex> Beaker.Gauge.get("set_gauge")
      3.14159

  Returns `:ok`
  """
  def set(key, value) do
    GenServer.cast(:beaker_gauges, {:set, key, value})
  end

  ## Server Callbacks

  @doc false
  def init(:ok) do
    {:ok, HashDict.new}
  end

  @doc false
  def handle_call(:all, _from, gauges) do
    {:reply, Enum.into(gauges, %{}), gauges}
  end

  @doc false
  def handle_call({:get, key}, _from, gauges) do
    {:reply, HashDict.get(gauges, key), gauges}
  end

  @doc false
  def handle_cast(:clear, _gauges) do
    {:noreply, HashDict.new}
  end

  @doc false
  def handle_cast({:set, key, value}, gauges) do
    {:noreply, HashDict.put(gauges, key, value)}
  end
end
