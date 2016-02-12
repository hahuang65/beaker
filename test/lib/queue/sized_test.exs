defmodule Queue.SizedTest do
  use ExUnit.Case

  test "Queue.Sized(size) should create a size bound queue of the given size" do
    queue = Queue.sized(2)
    assert queue.size == 2
  end

  test "Queue.add(sized_queue, item) should add the item into the sized_queue" do
    queue = Queue.sized(2)
    |> Queue.add(1)

    assert Enum.member?(queue, 1)
  end

  test "Queue.add(sized_queue, item) should push out the least recently added item if size overflows" do
    queue = Queue.sized(2)
    |> Queue.add(1)
    |> Queue.add(2)
    |> Queue.add(3)

    refute Enum.member?(queue, 1)

    assert Queue.items(queue) == [3, 2]
    assert Enum.count(queue) == 2
  end
end
