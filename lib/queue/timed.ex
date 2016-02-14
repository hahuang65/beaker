defmodule Queue.Timed do
  defstruct duration: nil, items: :queue.new()
end

defimpl Queueable, for: Queue.Timed do
  def add(queue = %Queue.Timed{duration: duration, items: items}, item = {time, _value}) do
    start = time - duration

    items = items
    |> :queue.to_list
    |> Enum.filter(fn({t, _}) ->
      t > start
    end)
    |> :queue.from_list

    %{queue | items: :queue.in_r(item, items)}
  end

  def items(%Queue.Timed{items: items}) do
    items
    |> :queue.to_list
    |> Enum.map(fn({_time, value}) ->
      value
    end)
  end
end
