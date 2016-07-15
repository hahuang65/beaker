defmodule Beaker.Web.Helper do
  @moduledoc false

  @colors ~w(yellow orange red magenta violet blue cyan green)

  def random_color do
    :random.seed(:os.timestamp)

    @colors
    |> Enum.shuffle
    |> hd
  end

  def ignore_time_series_count?(key) do
    ["Phoenix:ResponseTime", "Ecto:QueryTime", "Ecto:QueueTime"]
    |> Enum.member?(key)
  end

  def include_y_axis_title?(key) do
    ["Phoenix:ResponseTime", "Ecto:QueryTime", "Ecto:QueueTime"]
    |> Enum.member?(key)
  end

  def y_axis_title(key) do
    if include_y_axis_title?(key) do
      """
      title: {
        text: "Time (ms)"
      }
      """
    else
      """
      title: {
        text: null
      }
      """
    end
  end

  def time_series_count(key, series) do
    if ignore_time_series_count?(key) do
      ""
    else
      """
      {
        name: "Count",
        data: #{series.counts}
      },
      """
    end
  end

  def structure_time_series(data) do
    recent_data = data |> Enum.take(120)
    times = recent_data |> Enum.map(fn({time, _values}) -> Beaker.Time.to_gmt(time) end)
    avgs = recent_data |> Enum.map(fn({_time, {avg, _min, _max, _count}}) -> avg end)
    mins = recent_data |> Enum.map(fn({_time, {_avg, min, _max, _count}}) -> min end)
    maxs = recent_data |> Enum.map(fn({_time, {_avg, _min, max, _count}}) -> max end)
    cnts = recent_data |> Enum.map(fn({_time, {_avg, _min, _max, count}}) -> count end)

    averages = jsonify_data(Enum.zip(times, avgs))
    minimums = jsonify_data(Enum.zip(times, mins))
    maximums = jsonify_data(Enum.zip(times, maxs))
    counts = jsonify_data(Enum.zip(times, cnts))

    %Beaker.TimeSeries.Aggregated{averages: averages, minimums: minimums, maximums: maximums, counts: counts}
  end

  defp jsonify_data(data) do
    jsonify_data(data, "]")
  end
  defp jsonify_data([{{{year, month, day}, {hour, minute, _second}}, value} | tail], acc) do
    jsonify_data(tail, ",[Date.UTC(#{1970 + year}, #{month}, #{day}, #{hour}, #{minute}), #{value}]"  <> acc)
  end
  defp jsonify_data([], acc) do
    "[" <> String.slice(acc, 1..-1)
  end
end
