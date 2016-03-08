defmodule Beaker.Gauge do
  @name :beaker_gauges

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
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @doc """
  Retrieves all gauges in the form of a map.

  ## Examples

      iex> Beaker.Gauge.clear
      :ok
      iex> Beaker.Gauge.set("all_gauge1", 10, 0, 100)
      :ok
      iex> Beaker.Gauge.set("all_gauge2", 1, 0, 100)
      :ok
      iex> Beaker.Gauge.all
      %{"all_gauge1" => %{max: 100, min: 0, name: "all_gauge1", value: 10},
      "all_gauge2" => %{max: 100, min: 0, name: "all_gauge2", value: 1}}

  Returns `gauges` where gauges is a map of all the gauges currently existing.
  """
  def all do
    GenServer.call(@name, :all)
  end


  @doc """
  Clears all gauges stored in Beaker.

  ## Examples

      iex> Beaker.Gauge.clear
      :ok
      iex> Beaker.Gauge.set("all_gauge1", 10, 0, 100)
      :ok
      iex> Beaker.Gauge.set("all_gauge2", 1, 0, 100)
      :ok
      iex> Beaker.Gauge.all
      %{"all_gauge1" => %{max: 100, min: 0, name: "all_gauge1", value: 10},
      "all_gauge2" => %{max: 100, min: 0, name: "all_gauge2", value: 1}}
      iex> Beaker.Gauge.clear
      :ok
      iex> Beaker.Gauge.all
      %{}

  Returns `:ok`.
  """
  def clear do
    GenServer.cast(@name, :clear)
  end

  @doc """
  Clears the specified gauge from Beaker.

  ## Parameters
    * `key`: The name of the gauge to clear.

  ## Examples

      iex> Beaker.Gauge.clear
      :ok
      iex> Beaker.Gauge.set("all_gauge1", 10, 0, 100)
      :ok
      iex> Beaker.Gauge.set("all_gauge2", 1, 0, 100)
      :ok
      iex> Beaker.Gauge.all
      %{"all_gauge1" => %{max: 100, min: 0, name: "all_gauge1", value: 10},
      "all_gauge2" => %{max: 100, min: 0, name: "all_gauge2", value: 1}}
      iex> Beaker.Gauge.clear("all_gauge1")
      :ok
      iex> Beaker.Gauge.all
      %{"all_gauge2" => %{max: 100, min: 0, name: "all_gauge2", value: 1}}

  Returns `:ok`.
  """
  def clear(key) do
    GenServer.cast(@name, {:clear, key})
  end

  @doc """
  Retrieves the current value of the specified gauge.

  ## Parameters
    * `key`: The name of the gauge to retrieve.

  ## Examples

      iex> Beaker.Gauge.set("get_gauge", 50, 0, 100)
      :ok
      iex> Beaker.Gauge.get("get_gauge")
      %{max: 100, min: 0, name: "get_gauge", value: 50}

  Returns `count` where count is an integer if the gauge exists, else `nil`.
  """
  def get(key) do
    GenServer.call(@name, {:get, key})
  end

  @doc """
  ** DEPRECATED **

  It is now expected that you set a min and max value for a gauge, rather than just a value.
  Please use set/4 instead.

  """
  def set(key, value) do
    IO.write(:stderr, IO.ANSI.format([:red, :bright, "[DEPRECATION]: set/2 is being deprecated, please use set/4 instead\n" <> Exception.format_stacktrace()]))
    set(key, value, 0, 100)
  end

  @doc """
  Sets gauge with min max values

  ## Parameters
    * `key`: The name of the gauges to set the value for.
    * `value`: The value to set for the gauge
    * `min`: The lowest value for the gauge
    * `max`: The highest value for the gauge

  ## Examples

      iex> Beaker.Gauge.set("latency", 70, 0, 1000)
      :ok
      iex> Beaker.Gauge.get("latency")
      %{name: "latency", value: 70, min: 0, max: 1000}


   """

  def set(key, value, min, max) do
    GenServer.cast(@name, {:set, key, value, min, max})
  end


  @doc """
  Times the provided function and sets the duration to the gauge with the specified key.

  ## Parameters
    * `key`: The name of the gauge to set the duration to.
    * `func`: The function perform and time.

  ## Examples

      iex> Beaker.Gauge.time("time_gauge", fn -> :timer.sleep(50); 2 + 2 end)
      4
      iex> Beaker.Gauge.get("time_gauge") > 50
      true
      iex> Beaker.Gauge.time "time_gauge", do: 3 + 3
      6

  Returns `value` where value is the return value of the function that was performed.
  """
  defmacro time(key, do: block) do
    quote do
      Beaker.Gauge.time(unquote(key), fn -> unquote(block) end)
    end
  end
  defmacro time(key, func) do
    quote do
      {time, value} = :timer.tc(unquote(func))
      Beaker.Gauge.set(unquote(key), time, 0, 100)

      value
    end
  end

  ## Server Callbacks

  @doc false
  def init(:ok) do
    {:ok, Map.new}
  end

  @doc false
  def handle_call(:all, _from, gauges) do
    {:reply, Enum.into(gauges, %{}), gauges}
  end

  @doc false
  def handle_call({:get, key}, _from, gauges) do
    {:reply, Map.get(gauges, key), gauges}
  end

  @doc false
  def handle_cast(:clear, _gauges) do
    {:noreply, Map.new}
  end

  @doc false
  def handle_cast({:clear, key}, gauges) do
    {:noreply, Map.delete(gauges, key)}
  end

  @doc false
  def handle_cast({:set, key, value}, gauges) do
    {:noreply, Map.put(gauges, key, value)}
  end

  @doc false

  def handle_cast({:set, key, value, min, max}, gauges) do
    {:noreply, Map.put(gauges, key, %{name: key, min: min, max: max, value: value})}
  end
end
