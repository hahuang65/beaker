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
      iex> Beaker.Gauge.set("all_gauge1", 10)
      :ok
      iex> Beaker.Gauge.set("all_gauge2", 1)
      :ok
      iex> Beaker.Gauge.all
      %{"all_gauge1" => 10, "all_gauge2" => 1}

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
    GenServer.cast(@name, :clear)
  end

  @doc """
  Clears the specified gauge from Beaker.

  ## Examples

      iex> Beaker.Gauge.clear
      :ok
      iex> Beaker.Gauge.set("all_gauge1", 10)
      :ok
      iex> Beaker.Gauge.set("all_gauge2", 1)
      :ok
      iex> Beaker.Gauge.all
      %{"all_gauge1" => 10, "all_gauge2" => 1}
      iex> Beaker.Gauge.clear("all_gauge1")
      :ok
      iex> Beaker.Gauge.all
      %{"all_gauge2" => 1}

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

      iex> Beaker.Gauge.set("get_gauge", 50)
      :ok
      iex> Beaker.Gauge.get("get_gauge")
      50

  Returns `count` where count is an integer if the gauge exists, else `nil`.
  """
  def get(key) do
    GenServer.call(@name, {:get, key})
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
    GenServer.cast(@name, {:set, key, value})
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
      Beaker.Gauge.set(unquote(key), time)

      value
    end
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
  def handle_cast({:clear, key}, gauges) do
    {:noreply, HashDict.delete(gauges, key)}
  end

  @doc false
  def handle_cast({:set, key, value}, gauges) do
    {:noreply, HashDict.put(gauges, key, value)}
  end
end
