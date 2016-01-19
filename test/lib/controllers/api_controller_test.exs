defmodule Beaker.Controllers.MetricsApiControllerTest do
  use ExUnit.Case
  use Plug.Test
  import Plug.Conn

  setup do
    Beaker.Counter.clear
    Beaker.Counter.set("api", 1)
  end

  test "GET /api/counters" do
    response = conn(:get, "/api/counters") |> send_request

    assert response.status == 200

    decoded = Poison.decode!(response.resp_body)

    assert decoded == %{"api" => 1}
  end

  defp send_request(conn) do
    conn
    |> put_private(:plug_skip_csrf_protection, true)
    |> Plug.Conn.put_req_header("accepts", "application/json")
    |> Beaker.Router.call([])
  end
end
