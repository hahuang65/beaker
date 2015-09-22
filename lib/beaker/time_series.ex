defmodule Beaker.TimeSeries do
  @name :beaker_time_series

  @moduledoc """
  `Beaker.TimeSeries` is a simple time series. It's a metric that keeps track of values over time when sampled.

  It is commonly used to keep track of changing values over time to look at patterns and averages

  Examples are:
    * Response time across time
    * Download numbers over time
    * Error rates across time

  """

  ## Client API

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @doc """
  Retrieves all time series in the form of a HashDict.

  ## Examples

      iex> Beaker.TimeSeries.clear
      :ok
      iex> Beaker.TimeSeries.sample("all_series1", 10)
      :ok
      iex> Beaker.TimeSeries.sample("all_series2", 20)
      :ok
      iex> Beaker.TimeSeries.all |> HashDict.keys
      ["all_series1", "all_series2"]

  Returns `time_series` where time_series is a HashDict of all the time series currently existing.
  Each time series is returned as a list of pairs. Each pair is a timestamp in epoch and the value recorded.
  Each list is guaranteed to be in reverse chronological ordering, that is, the latest sample will be the first in the list.
  """
  def all do
    GenServer.call(@name, :all)
  end

  @doc """
  Remove all time series currently stored in Beaker.

  ## Examples

      iex> Beaker.TimeSeries.sample("clear_series1", 10)
      :ok
      iex> Beaker.TimeSeries.sample("clear_series2", 20)
      :ok
      iex> Beaker.TimeSeries.all |> Enum.empty?
      false
      iex> Beaker.TimeSeries.clear
      :ok
      iex> Beaker.TimeSeries.all |> Enum.empty?
      true

  Returns `:ok`.
  """
  def clear do
    GenServer.cast(@name, :clear)
  end

  @doc """
  Clears the specified time series from Beaker.

  ## Parameters
    * `key`: The name of the time series to clear.

  ## Examples

      iex> Beaker.TimeSeries.sample("clear_series1", 10)
      :ok
      iex> Beaker.TimeSeries.sample("clear_series2", 20)
      :ok
      iex> Beaker.TimeSeries.all |> HashDict.keys |> Enum.member?("clear_series1")
      true
      iex> Beaker.TimeSeries.all |> HashDict.keys |> Enum.member?("clear_series2")
      true
      iex> Beaker.TimeSeries.clear("clear_series1")
      :ok
      iex> Beaker.TimeSeries.all |> HashDict.keys |> Enum.member?("clear_series1")
      false
      iex> Beaker.TimeSeries.all |> HashDict.keys |> Enum.member?("clear_series2")
      true

  Returns `:ok`.
  """
  def clear(key) do
    GenServer.cast(@name, {:clear, key})
  end

  @doc """
  Get the time series for the given key.

  ## Parameters
    * `key`: The name of the time_series to retrieve.

  ## Examples

      iex> Beaker.TimeSeries.get("get_series")
      nil
      iex> Beaker.TimeSeries.sample("get_series", 10)
      :ok
      iex> Beaker.TimeSeries.get("get_series") |> Enum.count
      1

  Returns `time_series` where time_series is a list of the samples taken for the given key.
  """
  def get(key) do
    GenServer.call(@name, {:get, key})
  end

  @doc """
  Record a sample for the given key with the given value.

  ## Parameters
    * `key`: The name of the time_series to sample.
    * `value`: The value to save for the sample.

  ## Examples

      iex> Beaker.TimeSeries.sample("set_series", 5)
      :ok
      iex> Beaker.TimeSeries.get("set_series") |> hd |> elem(1)
      5

  Returns `time_series` where time_series is a list of the samples taken for that key.
  The list is guaranteed to be in reverse chronological ordering, that is, the latest sample will be the first in the list.
  Each sample is a pair that consists of a timestamp in epoch and the value recorded.
  """
  def sample(key, value) do
    GenServer.cast(@name, {:sample, key, value})
  end

  @doc """
  Times the provided function and samples the duration to the time series with the specified key.

  ## Parameters
    * `key`: The name of the time series to sample the duration to.
    * `func`: The function perform and time.

  ## Examples

      iex> Beaker.TimeSeries.time("time_time_series", fn -> :timer.sleep(50); 2 + 2 end)
      4
      iex> Beaker.TimeSeries.get("time_time_series") |> hd |> elem(1) > 50
      true
      iex> Beaker.TimeSeries.time "time_time_series", do: :timer.sleep(50); 3 + 3
      6

  Returns `value` where value is the return value of the function that was performed.
  """
  defmacro time(key, do: block) do
    quote do
      Beaker.TimeSeries.time(unquote(key), fn -> unquote(block) end)
    end
  end
  defmacro time(key, func) do
    quote do
      {time, value} = :timer.tc(unquote(func))
      Beaker.TimeSeries.sample(unquote(key), time)

      value
    end
  end

  ## Server Callbacks

  @doc false
  def init(:ok) do
    {:ok, HashDict.new}
  end

  @doc false
  def handle_call(:all, _from, time_series) do
    {:reply, time_series, time_series}
  end

  @doc false
  def handle_call({:get, key}, _from, time_series) do
    {:reply, HashDict.get(time_series, key), time_series}
  end

  @doc false
  def handle_cast(:clear, _time_series) do
    {:noreply, HashDict.new}
  end

  @doc false
  def handle_cast({:clear, key}, time_series) do
    {:noreply, HashDict.delete(time_series, key)}
  end

  @doc false
  def handle_cast({:sample, key, value}, time_series) do
    entry = {Beaker.Time.now, value}
    {:noreply, HashDict.update(time_series, key, [entry], fn(list) -> [entry | list] end)}
  end

end
