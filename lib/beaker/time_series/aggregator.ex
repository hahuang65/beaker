defmodule Beaker.TimeSeries.Aggregator do
  @name :beaker_time_series_aggregator
  @default_interval 60

  @moduledoc """
  `Beaker.TimeSeries.Aggregator` is the aggregation framework for time series. It's purposed mostly for internal use only.
  Currently, it's not configurable, and set to run every 60 seconds. This will change in the future to allow for more granularity.

  The only function that developers should use is `last_aggregated_at/0` to check when aggregation was last run.
  """

  ## Client API

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @doc """
  Get the last time aggregation was run for time series.

  ## Examples

    iex> Beaker.TimeSeries.Aggregator.last_aggregated_at
    1442946540000000

  Returns `last_aggregated_at` where last_aggregated_at is a timestamp of when the last time aggregation was successfully run.
  The timestamp is in epoch style, and in microseconds.
  """
  def last_aggregated_at do
    GenServer.call(@name, :last_aggregated_at)
  end

  @doc false
  def aggregate(data, before_time: before_time, after_time: after_time) when is_list(data) do
    interval = @default_interval

    data
    |> filter_by(before_time: before_time, after_time: after_time)
    |> batch_by(interval: interval)
    |> calculate_dimensions(interval: interval)
  end

  @doc false
  def aggregate(nil, _options), do: []

  @doc false
  def aggregate(time_series, before_time: before_time, after_time: after_time) do
    Beaker.TimeSeries.get(time_series)
    |> Beaker.TimeSeries.Aggregator.aggregate(before_time: before_time, after_time: after_time)
    |> Enum.map(fn({time, value}) ->
      Beaker.TimeSeries.Aggregated.insert(time_series, {time, value})
    end)
  end

  @doc false
  defp filter_by(data, before_time: before_time, after_time: after_time) do
    Enum.filter(data, fn({time, _value}) ->
      time >= after_time && time < before_time
    end)
  end

  @doc false
  defp batch_by(data, interval: interval) do
    Enum.group_by(data, fn({time, _value}) ->
      div(time, interval * 1000000)
    end)
  end

  @doc false
  defp calculate_dimensions(data, interval: interval) do
    Enum.map(data, fn({minute, pairs}) ->
      values = Enum.map(pairs, fn({_time, value}) -> value end)
      count = Enum.count(values)
      average =  Enum.sum(values) / count
      min = Enum.min(values)
      max = Enum.max(values)

      {minute * interval * 1000000, {average, min, max, count}}
    end)
  end

  ## Server Callbacks

  @doc false
  def init(:ok) do
    unless Mix.env == :test do
      :timer.send_interval(@default_interval * 1000, :schedule_aggregation)
    end
    {:ok, Beaker.Time.last_full_minute}
  end

  @doc false
  def handle_call(:last_aggregated_at, _from, last_aggregated_at) do
    {:reply, last_aggregated_at, last_aggregated_at}
  end

  @doc false
  def handle_info(:schedule_aggregation, last_aggregated_at) do
    Beaker.TimeSeries.all |> Map.keys
    |> Enum.each(fn(key) ->
      aggregate(key, before_time: Beaker.Time.last_full_minute, after_time: last_aggregated_at)
    end)

    {:noreply, Beaker.Time.last_full_minute}
  end
end
