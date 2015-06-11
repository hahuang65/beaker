if Code.ensure_loaded?(Phoenix.View) && Code.ensure_loaded?(Phoenix.HTML) do
  defmodule Beaker.MetricsView do
    @moduledoc false

    use Beaker.Web, :view
  end
end
