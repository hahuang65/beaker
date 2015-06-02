defmodule Beaker.Counter do
  ## Client API

  @doc """
  Start the Counter server
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :beaker_counters)
  end

  @doc """
  Retrieves the current value of the specified counter.

  ## Examples

      iex> Beaker.Counter.set("get_counter", 10)
      :ok
      iex> Beaker.Counter.get("get_counter")
      10

  Returns `count` where count is an integer if the counter exists, else `nil`.
  """
  def get(key) do
    GenServer.call(:beaker_counters, {:get, key})
  end

  @doc """
  Sets the value of the specified counter to the specified value.

  ## Examples

      iex> Beaker.Counter.set("set_counter", 10)
      :ok
      iex> Beaker.Counter.get("set_counter")
      10

  Returns `:ok`.
  """
  def set(key, value) do
    GenServer.cast(:beaker_counters, {:set, key, value})
  end

  @doc """
  Increments the specified counter by 1.

  ## Examples

      iex> Beaker.Counter.get("incr_counter")
      nil
      iex> Beaker.Counter.incr("incr_counter")
      :ok
      iex> Beaker.Counter.get("incr_counter")
      1

  Returns `:ok`.
  """
  def incr(key) do
    GenServer.cast(:beaker_counters, {:incr, key, 1})
  end

  @doc """
  Increments the specified counter by the specified number.

  ## Examples

      iex> Beaker.Counter.get("incr_by_counter")
      nil
      iex> Beaker.Counter.incr_by("incr_by_counter", 10)
      :ok
      iex> Beaker.Counter.get("incr_by_counter")
      10

  Returns `:ok`.
  """
  def incr_by(key, value) do
    GenServer.cast(:beaker_counters, {:incr, key, value})
  end

  @doc """
  Decrements the specified counter by 1.

  ## Examples

      iex> Beaker.Counter.get("decr_counter")
      nil
      iex> Beaker.Counter.decr("decr_counter")
      :ok
      iex> Beaker.Counter.get("decr_counter")
      -1

  Returns `:ok`.
  """
  def decr(key) do
    GenServer.cast(:beaker_counters, {:incr, key, -1})
  end

  @doc """
  Decrements the specified counter by the specified number.

  ## Examples

      iex> Beaker.Counter.get("decr_by_counter")
      nil
      iex> Beaker.Counter.decr_by("decr_by_counter", 10)
      :ok
      iex> Beaker.Counter.get("decr_by_counter")
      -10

  Returns `:ok`.
  """
  def decr_by(key, value) do
    GenServer.cast(:beaker_counters, {:incr, key, -value})
  end

  ## Server Callbacks

  @doc false
  def init(:ok) do
    {:ok, HashDict.new}
  end

  @doc false
  def handle_call({:get, key}, _from, counters) do
    {:reply, HashDict.get(counters, key), counters}
  end

  @doc false
  def handle_cast({:set, key, value}, counters) do
    {:noreply, HashDict.put(counters, key, value)}
  end

  @doc false
  def handle_cast({:incr, key, value}, counters) do
    {:noreply, HashDict.update(counters, key, value, fn(count) -> count + value end)}
  end
end
