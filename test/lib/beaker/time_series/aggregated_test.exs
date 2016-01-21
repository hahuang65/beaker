defmodule Beaker.TimeSeries.AggregatedTest do
  use ExUnit.Case
  doctest Beaker.TimeSeries.Aggregated

  alias Beaker.TimeSeries.Aggregated

  setup do
    on_exit fn ->
      Aggregated.clear
    end
  end

  test "Aggregated.get(key) returns nil if key is not yet registered as an aggregated time series" do
    assert Aggregated.get("nonexistent") == nil
  end

  test "Aggregated.get(key) returns the store value for key in the aggregated time series" do
    Aggregated.insert("get", {1, 2})

    [{1, 2}] = Aggregated.get("get")
  end

  test "Aggregated.clear returns :ok and erases all aggregated time series" do
    Aggregated.insert("clear", {1, 2})
    Aggregated.insert("clear", {3, 4})
    Aggregated.insert("clear", {5, 6})
    Aggregated.insert("clear", {7, 8})

    refute Aggregated.all |> Enum.empty?
    :ok = Aggregated.clear
  end

  test "Aggregated.clear(key) returns :ok and clears the specified aggregated time series" do
    Aggregated.insert("clear1", {1, 2})
    Aggregated.insert("clear1", {3, 4})
    Aggregated.insert("clear2", {5, 6})
    Aggregated.insert("clear2", {7, 8})

    assert Aggregated.all |> Map.keys |> Enum.member?("clear1")
    assert Aggregated.all |> Map.keys |> Enum.member?("clear2")
    :ok = Aggregated.clear("clear1")
    refute Aggregated.all |> Map.keys |> Enum.member?("clear1")
    assert Aggregated.all |> Map.keys |> Enum.member?("clear2")
  end

  test "Aggregated.all returns an empty Map if there are no aggregated time series" do
    Aggregated.clear
    assert Aggregated.all == Map.new
  end

  test "Aggregated.all returns a Map with all aggregated time series and values" do
    Aggregated.insert("all1", {1, 2})
    Aggregated.insert("all1", {3, 4})
    Aggregated.insert("all2", {5, 6})
    Aggregated.insert("all2", {7, 8})

    %{"all1" => [{3, 4}, {1, 2}], "all2" => [{7, 8}, {5, 6}]} = Aggregated.all |> Enum.into(%{})
  end

  test "Aggregated.insert will return :ok and record the passed in value for the given time under the time series of the given name" do
    :ok = Aggregated.insert("insert", {123, 456})
  end
end
