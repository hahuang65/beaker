if Code.ensure_loaded?(Phoenix.View) do
  defmodule Beaker.LayoutView do
    use Beaker.Web, :view
  end
end
