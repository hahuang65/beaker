if Code.ensure_loaded?(Phoenix.Controller) do
  defmodule Beaker.MetricsController do
    @moduledoc false

    use Beaker.Web, :controller

    plug :action

    def index(conn, _params) do
      render(conn, "index.html")
    end
  end
end
