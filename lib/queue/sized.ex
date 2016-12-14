defmodule Queue.Sized do
  defstruct size: nil, items: :queue.new()
end

defimpl Queueable, for: Queue.Sized do
  def add(queue = %Queue.Sized{size: size, items: items}, item) do
    new_items = if :queue.len(items) >= size do
      {_, its} = :queue.out_r(items)
      its
    else
      items
    end

    %{queue | items: :queue.in_r(item, new_items)}
  end

  def items(%Queue.Sized{items: items}), do: :queue.to_list(items)
end
