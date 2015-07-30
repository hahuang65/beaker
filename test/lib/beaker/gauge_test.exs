defmodule Beaker.GaugeTest do
  use ExUnit.Case
  doctest Beaker.Gauge

  alias Beaker.Gauge

  test "Gauge.all returns an empty map if there are no gauges" do
    Gauge.clear
    assert Gauge.all == %{}
  end

  test "Gauge.all returns a map with all gauges and values" do
    Gauge.clear
    Gauge.set("all1", 5)
    Gauge.set("all2", 2)
    assert Gauge.all == %{"all1" => 5, "all2" => 2}
  end

  test "Gauge.clear returns :ok and erases all gauges" do
    :ok = Gauge.set("clear1", 5)
    :ok = Gauge.set("clear2", 2)
    refute Gauge.all |> Enum.empty?
    Gauge.clear
    assert Gauge.all |> Enum.empty?
  end

  test "Gauge.clear(key) returns :ok and clears the specified gauge" do
    :ok = Gauge.set("clear1", 5)
    :ok = Gauge.set("clear2", 2)
    assert Gauge.all |> Map.keys |> Enum.member?("clear1")
    assert Gauge.all |> Map.keys |> Enum.member?("clear2")
    Gauge.clear("clear1")
    refute Gauge.all |> Map.keys |> Enum.member?("clear1")
    assert Gauge.all |> Map.keys |> Enum.member?("clear2")
  end

  test "Gauge.get(key) returns nil if name is not yet registered as a gauge" do
    assert Gauge.get("non-existent") == nil
  end

  test "Gauge.get(key) returns the stored value in the gauge" do
    Gauge.set("get", 50)
    assert Gauge.get("get") == 50
  end

  test "Gauge.set(key, value) sets the gauge to the value" do
    key = "set"
    assert Gauge.get(key) == nil
    Gauge.set(key, 10)
    assert Gauge.get(key) == 10
    Gauge.set(key, 2)
    assert Gauge.get(key) == 2
  end

  test "Gauge.set(key, value) accepts floats" do
    key = "set_float"
    Gauge.set(key, 3.14159)
    assert Gauge.get(key) == 3.14159
  end

  test "Gauge.time(key, fn -> :timer.sleep(500); :slept end) should set the gauge of the key to > 500 and return the value :slept" do
    key = "time_sleep"
    value = Gauge.time(key, fn -> :timer.sleep(50); :slept end)
    assert Gauge.get(key) > 50000 # :timer.tc returns in microseconds
    assert value == :slept
  end

  test "Gauge.time(key, [do: block]) alternative syntax works" do
    key = "time_sleep"
    value = Gauge.time(key) do
      :timer.sleep(50)
      :slept
    end

    assert Gauge.get(key) > 50000 # :timer.tc returns in microseconds
    assert value == :slept
  end
end
