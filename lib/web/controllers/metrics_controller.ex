if Code.ensure_loaded?(Phoenix.Controller) do
  defmodule Beaker.MetricsController do
    @moduledoc false

    use Beaker.Web, :controller

    def index(conn, _params) do
      counters = Beaker.Counter.all |> Enum.sort
      gauges = Beaker.Gauge.all |> Enum.sort
      render(conn, "index.html", counters: counters, gauges: gauges)
    end
  end
end
