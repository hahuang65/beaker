defmodule Beaker.Counter do
  @moduledoc """
  `Beaker.Counter` is a signed bi-directional integer counter.
  It can keep track of integers and increment and decrement them.

  It is commonly used for metrics that keep track of some cumulative value.

  Examples are:
    * Total number of downloads
    * Number of queued jobs
    * Quotas

  """

  ## Client API

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :beaker_counters)
  end

  @doc """
  Retrieves all counters in the form of a map.

  ## Examples

      iex> Beaker.Counter.clear
      :ok
      iex> Beaker.Counter.set("all_counter1", 10)
      :ok
      iex> Beaker.Counter.incr("all_counter2")
      :ok
      iex> Beaker.Counter.all
      %{"all_counter1" => 10, "all_counter2" => 1}

  Returns `counters` where counters is a map of all the counters currently existing.
  """
  def all do
    GenServer.call(:beaker_counters, :all)
  end


  @doc """
  Clears all counters stored in Beaker.

  ## Examples

      iex> Beaker.Counter.clear
      :ok
      iex> Beaker.Counter.set("all_counter1", 10)
      :ok
      iex> Beaker.Counter.incr("all_counter2")
      :ok
      iex> Beaker.Counter.all
      %{"all_counter1" => 10, "all_counter2" => 1}
      iex> Beaker.Counter.clear
      :ok
      iex> Beaker.Counter.all
      %{}

  Returns `:ok`.
  """
  def clear do
    GenServer.cast(:beaker_counters, :clear)
  end

  @doc """
  Clears the specified counter from Beaker.

  ## Examples

      iex> Beaker.Counter.clear
      :ok
      iex> Beaker.Counter.set("all_counter1", 10)
      :ok
      iex> Beaker.Counter.incr("all_counter2")
      :ok
      iex> Beaker.Counter.all
      %{"all_counter1" => 10, "all_counter2" => 1}
      iex> Beaker.Counter.clear("all_counter1")
      :ok
      iex> Beaker.Counter.all
      %{"all_counter2" => 1}

  Returns `:ok`.
  """
  def clear(key) do
    GenServer.cast(:beaker_counters, {:clear, key})
  end

  @doc """
  Retrieves the current value of the specified counter.

  ## Parameters
    * `key`: The name of the counter to retrieve.

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

  ## Parameters
    * `key`: The name of the counter to set the value for.
    * `value`: The value to set to the counter.

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

  ## Parameters
    * `key`: The name of the counter to increment.

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
  Increments the specified counter by the specified amount.

  ## Parameters
    * `key`: The name of the counter to increment.
    * `amount`: The amount to increment by.

  ## Examples

      iex> Beaker.Counter.get("incr_by_counter")
      nil
      iex> Beaker.Counter.incr_by("incr_by_counter", 10)
      :ok
      iex> Beaker.Counter.get("incr_by_counter")
      10

  Returns `:ok`.
  """
  def incr_by(key, amount) do
    GenServer.cast(:beaker_counters, {:incr, key, amount})
  end

  @doc """
  Decrements the specified counter by 1.

  ## Parameters
    * `key`: The name of the counter to decrement.

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
  Decrements the specified counter by the specified amount.

  ## Parameters
    * `key`: The name of the counter to decrement.
    * `amount`: The amount to decrement by.

  ## Examples

      iex> Beaker.Counter.get("decr_by_counter")
      nil
      iex> Beaker.Counter.decr_by("decr_by_counter", 10)
      :ok
      iex> Beaker.Counter.get("decr_by_counter")
      -10

  Returns `:ok`.
  """
  def decr_by(key, amount) do
    GenServer.cast(:beaker_counters, {:incr, key, -amount})
  end

  ## Server Callbacks

  @doc false
  def init(:ok) do
    {:ok, HashDict.new}
  end

  @doc false
  def handle_call(:all, _from, counters) do
    {:reply, Enum.into(counters, %{}), counters}
  end

  @doc false
  def handle_call({:get, key}, _from, counters) do
    {:reply, HashDict.get(counters, key), counters}
  end

  @doc false
  def handle_cast(:clear, _counters) do
    {:noreply, HashDict.new}
  end

  def handle_cast({:clear, key}, counters) do
    {:noreply, HashDict.delete(counters, key)}
  end

  @doc false
  def handle_cast({:set, key, value}, counters) do
    {:noreply, HashDict.put(counters, key, value)}
  end

  @doc false
  def handle_cast({:incr, key, amount}, counters) do
    {:noreply, HashDict.update(counters, key, amount, fn(count) -> count + amount end)}
  end
end
