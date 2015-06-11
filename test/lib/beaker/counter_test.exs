defmodule Beaker.CounterTest do
  use ExUnit.Case
  doctest Beaker.Counter

  alias Beaker.Counter

  test "Counter.all returns an empty map if there are no counters" do
    Counter.clear
    assert Counter.all == %{}
  end

  test "Counter.all returns a map with all counters and values" do
    Counter.clear
    Counter.set("all1", 5)
    Counter.set("all2", 2)
    assert Counter.all == %{"all1" => 5, "all2" => 2}
  end

  test "Counter.clear returns :ok and erases all counters" do
    Counter.clear
    Counter.set("clear1", 5)
    Counter.set("clear2", 2)
    assert Counter.all == %{"clear1" => 5, "clear2" => 2}
    Counter.clear
    assert Counter.all == %{}
  end

  test "Counter.get(key) returns nil if name is not yet registered as a counter" do
    assert Counter.get("non-existent") == nil
  end

  test "Counter.get(key) returns the stored value in the counter" do
    Counter.set("get", 50)
    assert Counter.get("get") == 50
  end

  test "Counter.set(key, value) sets the counter to the value" do
    key = "set"
    assert Counter.get(key) == nil
    Counter.set(key, 10)
    assert Counter.get(key) == 10
    Counter.set(key, 2)
    assert Counter.get(key) == 2
  end

  test "Counter.incr(key) increments the counter by 1" do
    key = "incr"
    assert Counter.get(key) == nil
    Counter.incr(key)
    assert Counter.get(key) == 1
    Counter.incr(key)
    assert Counter.get(key) == 2
  end

  test "Counter.incr_by(key, num) increments the counter by num" do
    key = "incr_by"
    num = 2
    assert Counter.get(key) == nil
    Counter.incr_by(key, num)
    assert Counter.get(key) == num
    Counter.incr_by(key, num)
    assert Counter.get(key) == num * 2
  end

  test "Counter.decr(key) decrements the counter by 1" do
    key = "decr"
    assert Counter.get(key) == nil
    Counter.decr(key)
    assert Counter.get(key) == -1
    Counter.decr(key)
    assert Counter.get(key) == -2
  end

  test "Counter.decr_by(key, num) decrements the counter by num" do
    key = "decr_by"
    num = 2
    assert Counter.get(key) == nil
    Counter.decr_by(key, num)
    assert Counter.get(key) == -num
    Counter.decr_by(key, num)
    assert Counter.get(key) == -(num * 2)
  end
end
