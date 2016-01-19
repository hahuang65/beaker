defmodule Beaker.Controllers.MetricsApiControllerTest do
  use ExUnit.Case
  use TestApp.ConnCase
  import Plug.Conn

  alias Beaker.Gauge
  alias Beaker.Counter
  alias Beaker.TimeSeries
  alias Beaker.TimeSeries.Aggregated

  setup do

    Counter.clear
    Gauge.clear
    TimeSeries.clear

    on_exit fn ->
      Counter.clear
      Gauge.clear
      TimeSeries.clear
    end
  end

  test "GET /api/counters" do
    Counter.set("api", 1)

    response = get_response("/api/counters")
    |> doc

    assert response.status == 200

    decoded = Poison.decode!(response.resp_body)

    assert decoded == %{"api" => 1}
  end

  test "GET /api/gauges" do
    Gauge.set("api_gauge", 100)

    response = get_response("/api/gauges")
    |> doc

    assert response.status == 200

    decoded = Poison.decode!(response.resp_body)

    assert decoded == %{"api_gauge" => 100}
  end

  test "GET /api/time_series" do
    TimeSeries.sample("api_time_series", 42)

    response = get_response("/api/time_series")
    |> doc

    assert response.status == 200

    decoded = Poison.decode!(response.resp_body)

    %{"time" => time, "value" => value} = decoded["api_time_series"] |> hd

    assert is_integer(time)
    assert is_integer(value)
  end
end
