defmodule TestApp.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Plug.Test

      def send_request(conn) do
        conn
        |> put_private(:plug_skip_csrf_protection, true)
        |> TestApp.call([])
      end
    end
  end
end
