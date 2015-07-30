defmodule Beaker.Web do
  @moduledoc false

  def view do
    quote do
      use Phoenix.View, root: "lib/web/templates"
      use Phoenix.HTML
    end
  end

  def controller do
    quote do
      use Phoenix.Controller
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  # Serves static files, otherwises passes connection to Beaker.Router.
  use Plug.Builder

  plug Plug.Static,
    at: "/", from: :beaker,
    only: ~w(css js)

  plug Beaker.Router
end
