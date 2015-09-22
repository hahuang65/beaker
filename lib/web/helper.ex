defmodule Beaker.Web.Helper do
  @moduledoc false

  @colors ~w(yellow orange red magenta violet blue cyan green)

  def random_color do
    :random.seed(:os.timestamp)

    @colors
    |> Enum.shuffle
    |> hd
  end

  def format_time_series_data(data) do
    data
    |> Enum.take(30)
    |> format_time_series_data("]")
  end
  defp format_time_series_data([{time, value} | tail], acc) do
    {{year, month, day}, {hour, minute, _second}} = Beaker.Time.to_gmt(time)
    format_time_series_data(tail, ",[Date.UTC(#{1970 + year}, #{month}, #{day}, #{hour}, #{minute}), #{value}]"  <> acc)
  end
  defp format_time_series_data([], acc) do
    "[" <> String.slice(acc, 1..-1)
  end
end
