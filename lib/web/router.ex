if Code.ensure_loaded?(Phoenix.Router) do
  defmodule Beaker.Router do
    @moduledoc """
    `Beaker.Router` is a router for Beaker integration into Phoenix.
    Importantly, it is NOT the entry point to Beaker from a Phoenix app.
    Instead, that should be `Beaker.Web`.

    To automatically be able to access a view with your Beaker metrics, you'll need to

    1) Add `beaker` and `phoenix` to the dependencies in your Mixfile:
    ```
    defp deps do
      [
        {:phoenix, ">= 0.14"},
        {:phoenix_html, ">= 1.2"}
      ]
    end
    ```

    2) Add `beaker` and `phoenix_html` to the started applications in your Mixfile:
    ```
    def application do
      applications: [:phoenix, :phoenix_html, :beaker]
    end
    ```

    3) Forward requests to `Beaker.Web` in your router:
    ```
    forward "/beaker", Beaker.Web
    ```
    """

    use Phoenix.Router

    def static_path(%Plug.Conn{script_name: script}, path), do: Path.join(script, "/") <> path

    pipeline :browser do
      plug :accepts, ~w(html)
    end

    scope "/", Beaker do
      pipe_through :browser

      get "/", MetricsController, :index
    end
  end
end
