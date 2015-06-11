if Code.ensure_loaded?(Phoenix.View) do
  defmodule Beaker.MetricsView do
    use Beaker.Web, :view
  end
end
