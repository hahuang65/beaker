defmodule Beaker.TimeSeriesTest do
  use ExUnit.Case
  doctest Beaker.TimeSeries

  alias Beaker.TimeSeries

  test "TimeSeries.all returns an empty map if there are no time series" do
    TimeSeries.clear
    assert TimeSeries.all == %{}
  end

  test "TimeSeries.all returns a map with all time series and values" do
    TimeSeries.clear
    TimeSeries.sample("all1", 20)
    TimeSeries.sample("all1", 55)
    TimeSeries.sample("all2", 10)
    TimeSeries.sample("all2", 45)

    %{"all1" => [{_time1, 55}, {_time2, 20}], "all2" => [{_time3, 45}, {_time4, 10}]} = TimeSeries.all
  end

  test "TimeSeries.clear returns :ok and erases all time series" do
    TimeSeries.sample("clear1", 20)
    TimeSeries.sample("clear1", 55)
    TimeSeries.sample("clear2", 10)
    TimeSeries.sample("clear2", 45)

    refute TimeSeries.all |> Enum.empty?
    TimeSeries.clear
    assert TimeSeries.all |> Enum.empty?
  end

  test "TimeSeries.sample will return :ok and record the value for the time series at that point in time as well as keep it in chronologically descending order" do
    assert TimeSeries.get("sample") == nil

    :ok = TimeSeries.sample("sample", 10)
    :ok = TimeSeries.sample("sample", 20)

    [{time2, 20}, {time1, 10}] = TimeSeries.get("sample")

    assert time2 > time1
  end

  test "TimeSeries.get(key) returns nil if name is not yet registered as a time series" do
    assert TimeSeries.get("non-existent") == nil
  end

  test "TimeSeries.get(key) returns the stored value in the time series" do
    TimeSeries.sample("get", 10)
    [{_time1, 10}] = TimeSeries.get("get")
  end
end
