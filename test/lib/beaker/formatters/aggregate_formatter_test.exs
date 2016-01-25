defmodule Beaker.Formatters.AggregateTest do
  use ExUnit.Case

  alias Beaker.TimeSeries

  setup do
    TimeSeries.Aggregated.clear
    TimeSeries.sample("aggregation_series1", 10)
    TimeSeries.sample("aggregation_series2", 20)
    TimeSeries.sample("aggregation_series3", 30)

    TimeSeries.Aggregator.aggregate("aggregation_series1", before_time: Beaker.Time.now + 5000, after_time: 0)
    TimeSeries.Aggregator.aggregate("aggregation_series2", before_time: Beaker.Time.now + 5000, after_time: 0)
    TimeSeries.Aggregator.aggregate("aggregation_series3", before_time: Beaker.Time.now + 5000, after_time: 0)

    on_exit fn ->
      TimeSeries.Aggregated.clear
    end

  end

  test "Converts aggregate to a map" do
    mapped = Beaker.Formatters.Aggregate.to_map(TimeSeries.Aggregated.all)

    keys = Map.keys(mapped)

    assert keys === ["aggregation_series1", "aggregation_series2", "aggregation_series3"]

    aggregation_series_1 = Map.get(mapped, "aggregation_series1")

    assert is_list(aggregation_series_1)

    measurement = aggregation_series_1 |> hd

    assert measurement.average == 10.0
    assert measurement.count == 1
    assert measurement.max == 10
    assert measurement.min == 10
    assert measurement.time != nil
  end

end
