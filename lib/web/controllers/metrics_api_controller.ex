if Code.ensure_loaded?(Phoenix.Controller) do
  defmodule Beaker.MetricsApiController do
    use Beaker.Web, :controller

    def counters(conn, _params) do
      counters = Beaker.Counter.all
      conn
      |> json(counters)
    end
  end
end

