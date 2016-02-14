defmodule Queue.TimedTest do
  use ExUnit.Case

  test "Queue.Timed(duration) should create a time bound queue of the given duration" do
    queue = Queue.timed(2)
    assert queue.duration == 2
  end

  test "Queue.add(timed_queue, item) should add the item into the timed_queue" do
    queue = Queue.timed(2)
    |> Queue.add({1, 1})

    assert Enum.member?(queue, 1)
  end

  test "Queue.add(timed_queue, item) should push out the least recently added item if duration expires" do
    queue = Queue.timed(2)
    |> Queue.add({1, 1})
    |> Queue.add({2, 2})
    |> Queue.add({3, 3})
    |> Queue.add({4, 4})

    assert Queue.items(queue) == [4, 3]
    assert Enum.count(queue) == 2
  end
end
