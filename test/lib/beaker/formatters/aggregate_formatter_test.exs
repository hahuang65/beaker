defmodule Beaker.Formatters.AggregateTest do
  use ExUnit.Case

  alias Beaker.TimeSeries

  @expected_output %{
  }

  setup do
    TimeSeries.Aggregated.clear
    TimeSeries.sample("time_series1", 10)
    TimeSeries.sample("time_series2", 20)
    TimeSeries.sample("time_series3", 30)

    TimeSeries.Aggregator.aggregate("time_series1", before_time: Beaker.Time.now + 5000, after_time: 0)
    TimeSeries.Aggregator.aggregate("time_series2", before_time: Beaker.Time.now + 5000, after_time: 0)
    TimeSeries.Aggregator.aggregate("time_series3", before_time: Beaker.Time.now + 5000, after_time: 0)

    on_exit fn ->
      TimeSeries.Aggregated.clear
    end

  end

  test "Converts aggregate to a map" do
    mapped = Beaker.Formatters.Aggregate.to_map(TimeSeries.Aggregated.all)

    keys = Map.keys(mapped)

    assert keys === ["time_series1", "time_series2", "time_series3"]

    time_series_1 = Map.get(mapped, "time_series1")

    assert is_list(time_series_1)

    measurement = time_series_1 |> hd

    assert get_value(measurement) == %{average: 10.0, count: 1, max: 10, min: 10}
  end

  defp get_value(map) do
    key = Map.keys(map) |> hd
    Map.get(map, key)
  end
end
