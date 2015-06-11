if Code.ensure_loaded?(Phoenix.View) && Code.ensure_loaded?(Phoenix.HTML) do
  defmodule Beaker.LayoutView do
    @moduledoc false

    use Beaker.Web, :view
  end
end
