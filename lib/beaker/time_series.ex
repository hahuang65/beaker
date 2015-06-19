defmodule Beaker.TimeSeries do
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
    GenServer.start_link(__MODULE__, :ok, name: :beaker_time_series)
  end

  @doc """
  Retrieves all time series in the form of a map.

  ## Examples

      iex> Beaker.TimeSeries.clear
      :ok
      iex> Beaker.TimeSeries.sample("all_series1", 10)
      :ok
      iex> Beaker.TimeSeries.sample("all_series2", 20)
      :ok
      iex> Beaker.TimeSeries.all |> Map.keys
      ["all_series1", "all_series2"]

  Returns `time_series` where time_series is a map of all the time_series currently existing.
  """
  def all do
    GenServer.call(:beaker_time_series, :all)
  end

  @doc """
  Remove all time seriess currently stored in Beaker.

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
    GenServer.cast(:beaker_time_series, :clear)
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
    GenServer.call(:beaker_time_series, {:get, key})
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
  """
  def sample(key, value) do
    GenServer.cast(:beaker_time_series, {:sample, key, value})
  end

  @doc false
  defp now_in_epoch do
    {mega, sec, micro} = :os.timestamp()
    (mega * 1000000 + sec) * 1000000 + micro
  end

  ## Server Callbacks

  @doc false
  def init(:ok) do
    {:ok, HashDict.new}
  end

  @doc false
  def handle_call(:all, _from, time_series) do
    {:reply, Enum.into(time_series, %{}), time_series}
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
  def handle_cast({:sample, key, value}, time_series) do
    entry = {now_in_epoch(), value}
    {:noreply, HashDict.update(time_series, key, [entry], fn(list) -> [entry | list] end)}
  end

end
