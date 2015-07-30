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

  test "TimeSeries.clear(key) returns :ok and clears the specified time series" do
    TimeSeries.sample("clear1", 20)
    TimeSeries.sample("clear1", 55)
    TimeSeries.sample("clear2", 10)
    TimeSeries.sample("clear2", 45)
    assert Beaker.TimeSeries.all |> Map.keys |> Enum.member?("clear1")
    assert Beaker.TimeSeries.all |> Map.keys |> Enum.member?("clear2")
    TimeSeries.clear("clear1")
    refute Beaker.TimeSeries.all |> Map.keys |> Enum.member?("clear1")
    assert Beaker.TimeSeries.all |> Map.keys |> Enum.member?("clear2")
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

  test "TimeSeries.time(key, fn -> :timer.sleep(500); :slept end) should set the time series of the key to > 500 and return the value :slept" do
    key = "time_sleep"
    value = TimeSeries.time(key, fn -> :timer.sleep(50); :slept end)
    assert TimeSeries.get(key) |> hd |> elem(1) > 50000 # :timer.tc returns in microseconds.
    assert value == :slept
  end

  test "TimeSeries.time(key, [do: block]) alternative syntax works" do
    key = "time_sleep"
    value = TimeSeries.time(key) do
      :timer.sleep(50)
      :slept
    end

    assert TimeSeries.get(key) |> hd |> elem(1) > 50000 # :timer.tc returns in microseconds
    assert value == :slept
  end

  test "TimeSeries.time/2 will prepend to the TimeSeries and not overwrite it" do
    TimeSeries.clear

    key = "time_append"
    TimeSeries.sample(key, 50)

    assert TimeSeries.get(key) |> Enum.count == 1

    TimeSeries.time(key, fn -> 1 + 1 end)

    assert TimeSeries.get(key) |> Enum.count == 2
    assert TimeSeries.get(key) |> Enum.reverse |> hd |> elem(1) == 50
  end
end
