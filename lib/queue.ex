defprotocol Queueable do
  def add(queue, item)
  def items(queue)
end

defmodule Queue do
  def sized(size), do: %Queue.Sized{size: size}
  def timed(duration), do: %Queue.Timed{duration: duration}
  def timed(duration, initial_value) do
    %Queue.Timed{duration: duration}
    |> Queue.add(initial_value)
  end

  def add(queue, item), do: Queueable.add(queue, item)
  def items(queue), do: Queueable.items(queue)
end

defimpl Enumerable, for: [Queue.Sized, Queue.Timed] do
  def count(queue) do
    {:ok, length(Queue.items(queue))}
  end

  def member?(queue, value) do
    {:ok, Enum.member?(Queue.items(queue), value)}
  end

  def reduce(_, {:halt, acc}, _fun),  do: {:halted, acc}
  def reduce(queue, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(queue, &1, fun)}
  def reduce(queue = %{items: items}, {:cont, acc}, fun) do
    if :queue.len(items) == 0 do
      {:done, acc}
    else
      h = :queue.head(items)
      reduce(%{queue | items: :queue.tail(items)}, fun.(h, acc), fun)
    end
  end
end
