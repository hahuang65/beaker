defmodule Beaker.GaugeTest do
  use ExUnit.Case
  doctest Beaker.Gauge

  alias Beaker.Gauge

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
end
