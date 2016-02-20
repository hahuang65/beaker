defmodule Beaker.TimeSeries.Aggregated do
  @name :beaker_aggregated_time_series

  @moduledoc """
  `Beaker.TimeSeries.Aggregated` is the datastore for aggregated time series data. It's purposed mostly for internal use only.

  The only two functions that developers should use are `get/1` and `all/0` in order to get aggregated time series data out.
  """

  @doc false
  defstruct averages: "", minimums: "", maximums: "", counts: ""

  ## Client API

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @doc """
  Get the aggregated time series data for the given key.

  ## Parameters
    * `key`: The name of the aggregated time_series to retrieve.

  ## Examples

    iex> Beaker.TimeSeries.Aggregated.get("get_series")
    nil
    iex> Beaker.TimeSeries.Aggregated.insert("get_series", {1, 2})
    :ok
    iex> Beaker.TimeSeries.Aggregated.get("get_series")
    [{1, 2}]

  Returns `time_series` where time_series is a list of the data entries aggregated for the given key.
  """
  def get(key) do
    GenServer.call(@name, {:get, key})
  end

  @doc """
  Retrieves all aggregated time series in the form of a Map.

  ## Examples

    iex> Beaker.TimeSeries.Aggregated.clear
    :ok
    iex> Beaker.TimeSeries.Aggregated.insert("all_series1", {1, 2})
    :ok
    iex> Beaker.TimeSeries.Aggregated.insert("all_series2", {3, 4})
    :ok
    iex> Beaker.TimeSeries.Aggregated.all |> Enum.into(%{})
    %{"all_series1" => [{1, 2}], "all_series2" => [{3, 4}]}

  Returns `time_series` where time_series is a Map of all the aggregated time series currently existing.
  Each time series is returned as a list of pairs. Each pair is a timestamp in epoch (aggregated to the nearest aggregation interval) and the value recorded.
  Each list is guaranteed to be in reverse chronological ordering, that is, the latest aggregated interval will be the first in the list.
  """
  def all do
    GenServer.call(@name, :all)
  end

  @doc false
  def clear do
    GenServer.cast(@name, :clear)
  end

  @doc false
  def clear(key) do
    GenServer.cast(@name, {:clear, key})
  end

  @doc false
  def insert(key, {time, value}) do
    GenServer.cast(@name, {:insert, key, {time, value}})
  end

  ## Server Callbacks

  @doc false
  def init(:ok) do
    {:ok, Map.new}
  end

  @doc false
  def handle_call({:get, key}, _from, time_series) do
    queue = time_series
    |> Map.get(key)

    results = if queue do
      queue
      |> Map.get(:items)
      |> :queue.to_list
    end

    {:reply, results, time_series}
  end

  @doc false
  def handle_call(:all, _from, time_series) do
    results = time_series
    |> Enum.into(%{}, fn({name, queue}) ->
      {name, Map.get(queue, :items) |> :queue.to_list}
    end)

    {:reply, results, time_series}
  end

  @doc false
  def handle_cast(:clear, _time_series) do
    {:noreply, Map.new}
  end

  @doc false
  def handle_cast({:clear, key}, time_series) do
    {:noreply, Map.delete(time_series, key)}
  end

  @doc false
  def handle_cast({:insert, key, entry = {_time, _value}}, time_series) do
    duration = Beaker.Time.microseconds_from(hours: 2)

    {:noreply, Map.update(time_series, key, Queue.timed(duration, entry), fn(queue) -> Queue.add(queue, entry) end)}
  end
end
