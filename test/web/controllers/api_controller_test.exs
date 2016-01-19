defmodule Beaker.Controllers.MetricsApiControllerTest do
  use ExUnit.Case
  use Plug.Test
  import Plug.Conn

  setup do
    on_exit fn ->
      Beaker.Counter.clear
      Beaker.Gauge.clear
      Beaker.TimeSeries.clear
    end
  end

  test "GET /api/counters" do
    Beaker.Counter.set("api", 1)

    response = conn(:get, "/api/counters") |> send_request

    assert response.status == 200

    decoded = Poison.decode!(response.resp_body)

    assert decoded == %{"api" => 1}
  end

  test "GET /api/gauges" do
    Beaker.Gauge.set("api_gauge", 100)

    response = conn(:get, "/api/gauges") |> send_request

    assert response.status == 200

    decoded = Poison.decode!(response.resp_body)

    assert decoded == %{"api_gauge" => 100}
  end

  test "GET /api/time_series" do
    Beaker.TimeSeries.sample("api_time_series", 42)

    response = conn(:get, "/api/time_series") |> send_request

    assert response.status == 200

    decoded = Poison.decode!(response.resp_body)

    %{"time" => time, "value" => value} = decoded["api_time_series"] |> hd

    assert is_integer(time)
    assert is_integer(value)
  end

  defp send_request(conn) do
    conn
    |> put_private(:plug_skip_csrf_protection, true)
    |> Plug.Conn.put_req_header("accepts", "application/json")
    |> Beaker.Router.call([])
  end
end
