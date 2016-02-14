defmodule Queue.Sized do
  defstruct size: nil, items: :queue.new()
end

defimpl Queueable, for: Queue.Sized do
  def add(queue = %Queue.Sized{size: size, items: items}, item) do
    if :queue.len(items) >= size do
      {_, items} = :queue.out_r(items)
    end

    %{queue | items: :queue.in_r(item, items)}
  end

  def items(%Queue.Sized{items: items}), do: :queue.to_list(items)
end
