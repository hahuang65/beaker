if Code.ensure_loaded?(Phoenix.Controller) do
  defmodule Beaker.MetricsController do
    @moduledoc false

    use Beaker.Web, :controller

    def index(conn, _params) do
      counters = Beaker.Counter.all |> Enum.sort
      gauges = Beaker.Gauge.all |> Enum.sort
      time_series = Beaker.TimeSeries.Aggregated.all |> Enum.sort
      render(conn, "index.html", counters: counters, gauges: gauges, time_series: time_series)
    end
  end
end
