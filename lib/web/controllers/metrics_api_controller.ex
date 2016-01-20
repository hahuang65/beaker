if Code.ensure_loaded?(Phoenix.Controller) do
  defmodule Beaker.MetricsApiController do
    use Beaker.Web, :controller

    def counters(conn, _params) do
      counters = Beaker.Counter.all
      conn
      |> json(counters)
    end

    def gauges(conn, _param) do
      gauges = Beaker.Gauge.all
      conn
      |> json(gauges)
    end

    def time_series(conn, _params) do
      time_series = Beaker.TimeSeries.all
      |> format_time_series
      conn
      |> json(time_series)
    end

    def aggregated(conn, _params) do
      aggregated = Beaker.TimeSeries.Aggregated.all
      |> aggregate_to_json

      conn
      |> json(aggregated)
    end

    # %{"Phoenix:ResponseTime" => [{1453257960000000,
    #  {28.875111111111103, 0.025, 54.857, 54}},
    #  {1453257900000000, {30.28651111111112, 0.024, 62.44, 90}},
    #  {1453257840000000, {37.56753846153846, 0.055, 81.287, 13}}
    #  ]}


    defp aggregate_to_json(agg) do
      Enum.reduce(agg, %{}, fn {key, value}, acc ->
        Map.put(acc, key, Enum.map(value, &aggregate_tuple_to_map/1))
      end)
    end

    defp aggregate_tuple_to_map({_time, {avg, min, max, count}}) do
      %{average: avg, min: min, max: max, count: count}
    end

    defp format_time_series(series) do
      Enum.reduce(series, %{}, fn {key, value}, acc ->
        Map.put(acc, key,  Enum.map(value, &tuples_to_map/1))
      end)
    end

    defp tuples_to_map({time, value}) do
      %{time: time, value: value}
    end

  end
end

