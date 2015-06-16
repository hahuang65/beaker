if Code.ensure_loaded?(Phoenix.Controller) do
  defmodule Beaker.MetricsController do
    @moduledoc false

    use Beaker.Web, :controller

    plug :action

    def index(conn, _params) do
      counters = Beaker.Counter.all
      gauges = Beaker.Gauge.all
      render(conn, "index.html", counters: counters, gauges: gauges)
    end
  end
end
