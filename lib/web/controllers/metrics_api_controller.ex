if Code.ensure_loaded?(Phoenix.Controller) do
  defmodule Beaker.MetricsApiController do
    use Beaker.Web, :controller

    def counters(conn, _params) do
      counters = Beaker.Counter.all
      |> Enum.map(fn {key, value} -> %{measurement: key, value: value} end)

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
      |> Beaker.Formatters.Aggregate.to_map

      conn
      |> json(aggregated)
    end

    defp format_time_series(series) do
      Enum.reduce(series, %{}, fn {key, value}, acc ->
        values = Enum.take(value, 120)
        Map.put(acc, key,  Enum.map(values, &tuples_to_map/1))
      end)
    end

    defp tuples_to_map({time, value}) do
      time_as_milliseconds = Beaker.Time.to_milliseconds(time)
      %{time: time_as_milliseconds, value: value}
    end

  end
end

