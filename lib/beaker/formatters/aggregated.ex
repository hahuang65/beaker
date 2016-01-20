defmodule Beaker.Formatters.Aggregate do

  # INPUT
  # %{"time_series1" => [
  #    {1453273140000000, {10.0, 10, 10, 1}}
  #  ],
  #   "time_series2" => [
  #     {1453273140000000, {20.0, 20, 20, 1}}
  #   ], "time_series3" => [
  #     {1453273140000000, {30.0, 30, 30, 1}}
  #   ]
  #  }

  def to_map(data) do
    Enum.reduce(data, %{}, fn {key, value}, agg ->
      values = Enum.map(value, &get_values/1)
      Map.put(agg, key, values)
    end)
  end

  def get_values([]), do: []

  def get_values([head | tail]) do
    [tail | get_values(head)]
  end

  def get_values({time, {avg, min,  max, count}}) do
    Map.put(%{}, "#{time}", %{average: avg, min: min, max: max, count: count})
  end
end
