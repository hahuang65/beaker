defmodule TestApp.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Plug.Test
      import Bureaucrat.Helpers

      defp send_request(conn) do
        conn
        |> put_private(:plug_skip_csrf_protection, true)
        |> Plug.Conn.put_req_header("accepts", "application/json")
        |> Beaker.Router.call([])
      end

      defp get_response(endpoint) do
        conn(:get, endpoint)
        |> send_request
      end
    end
  end
end
