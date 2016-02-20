defmodule Beaker.TimeSeries.AggregatorTest do
  use ExUnit.Case

  alias Beaker.TimeSeries.Aggregator
  alias Beaker.TimeSeries.Aggregated

  setup do
    on_exit fn ->
      Beaker.TimeSeries.clear
    end
  end

  test "Aggregator.aggregate(data, before:_time before, after:_time after) aggregates properly" do
    data = [{119000000, 4}, {63000000, 3}, {61000000, 2}, {30000000, 8}, {1000000, 6}]
    assert Aggregator.aggregate(data, before_time: Beaker.Time.now, after_time: 0) == [{0, {7.0, 6, 8, 2}}, {60000000, {3.0, 2, 4, 3}}]
  end

  test "Aggregate.aggregate(nil, before_time: before, after:_time after) returns an empty list" do
    assert Aggregator.aggregate(nil, before_time: Beaker.Time.now, after_time: 0) == []
  end

  test "Aggregate.aggregate(data, before_time: before, after_time: after) ignores data before the passed in after_time" do
    data = [{Beaker.Time.now, 10}]
    assert Aggregator.aggregate(data, before_time: Beaker.Time.now + 60000, after_time: Beaker.Time.now + 30000) == []
  end

  test "Aggregate.aggregate(data, before_time: before, after_time: after) ignores data after the passed in before_time" do
    data = [{Beaker.Time.now, 15}]
    assert Aggregator.aggregate(data, before_time: Beaker.Time.now - 30000, after_time: Beaker.Time.now - 60000) == []
  end

  test "Aggregator.aggregate(time_series, before_time: before, after_time: after) will populate the correct TimeSeries.Aggregated" do
    opts = [before_time: Beaker.Time.now + 60000, after_time: 0]
    Beaker.TimeSeries.sample("aggregator1", 50)
    assert Aggregated.get("aggregator1") == nil
    Aggregator.aggregate("aggregator1", opts)
    refute Aggregated.get("aggregator1") == nil
  end

  test "Aggregator.aggregate(time_series, before_time: before, after_time: after) should aggregate the data of time_series into intervals" do
    opts = [before_time: Beaker.Time.now + 60000, after_time: 0]

    Beaker.TimeSeries.sample("aggregator2", 10)
    Beaker.TimeSeries.sample("aggregator2", 20)
    Beaker.TimeSeries.sample("aggregator2", 30)

    expected = Beaker.TimeSeries.get("aggregator2")
    |> Aggregator.aggregate(opts)

    refute Aggregated.get("aggregator2") == expected
    Aggregator.aggregate("aggregator2", opts)

    assert Aggregated.get("aggregator2") == expected
  end

  test "Aggregator.aggregate(nonexistent_time_series, before_time: before, after_time: after) will not populate anything into TimeSeries.Aggregated" do
    opts = [before_time: Beaker.Time.now + 60000, after_time: 0]
    Aggregator.aggregate("nonexistent_time_series", opts)
    assert Aggregated.get("nonexistent_time_series") == nil
  end

  test "Aggregation is under 50ms for 600 points of data within a minute" do
    stream = Stream.repeatedly(fn ->
      :random.seed(:os.timestamp)
      :random.uniform * :random.uniform * 100
    end)

    Stream.take(stream, 600)
    |> Stream.each(fn(num) ->
      Beaker.TimeSeries.sample("performance1", num)
    end)
    |> Enum.to_list

    {time, _value} = :timer.tc(fn -> Aggregator.aggregate("performance1", before_time: Beaker.Time.now, after_time: 0) end)
    assert time < 50000
  end

  test "Aggregation is under 500ms for 600 points of data within a minute for 10 time series" do
    stream = Stream.repeatedly(fn ->
      :random.seed(:os.timestamp)
      :random.uniform * :random.uniform * 100
    end)

    Stream.take(stream, 600)
    |> Stream.each(fn(num) ->
      ~w(1 2 3 4 5 6 7 8 9 10) |> Enum.each(fn(count) ->
        Beaker.TimeSeries.sample("performance2" <> count, num)
      end)
    end)
    |> Enum.to_list

    {time, _value} = :timer.tc(fn ->
      Beaker.TimeSeries.all |> Map.keys
      |> Enum.each(fn(key) ->
        Aggregator.aggregate(key, before_time: Beaker.Time.now, after_time: 0)
      end)
    end)
    assert time < 500000
    assert Aggregated.all |> Enum.filter(fn({name, _data}) -> String.contains?(name, "performance2") end) |> Enum.count == 10
  end
end
