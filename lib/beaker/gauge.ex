defmodule Beaker.Gauge do
  ## Client API

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :beaker_gauges)
  end

  @doc """
  Retrieves the current value of the specified gauge.

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
  def handle_call({:get, key}, _from, gauges) do
    {:reply, HashDict.get(gauges, key), gauges}
  end

  @doc false
  def handle_cast({:set, key, value}, gauges) do
    {:noreply, HashDict.put(gauges, key, value)}
  end
end
