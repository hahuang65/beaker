defmodule Beaker.Controllers.MetricsApiControllerTest do
  use ExUnit.Case
  use TestApp.ConnCase
  import Plug.Conn

  alias Beaker.Gauge
  alias Beaker.Counter
  alias Beaker.TimeSeries

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
    Counter.set("api_counter", 1)

    response = get_response("/api/counters")
    |> doc

    assert response.status == 200

    decoded = Poison.decode!(response.resp_body)

    assert decoded == [%{"name" => "api_counter", "value" => 1}]
  end

  test "GET /api/gauges" do
    Gauge.set("api_gauge", 100)

    response = get_response("/api/gauges")
    |> doc

    assert response.status == 200

    decoded = Poison.decode!(response.resp_body)

    assert decoded == %{"api_gauge" => %{"max" => 100, "min" => 0, "name" => "api_gauge",
                                         "value" => 100}}
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

  test "GET /api/aggregated" do
    TimeSeries.Aggregated.clear
    TimeSeries.sample("time_series1", 10)
    TimeSeries.sample("time_series2", 20)
    TimeSeries.sample("time_series3", 30)

    TimeSeries.Aggregator.aggregate("time_series1", before_time: Beaker.Time.now + 5000, after_time: 0)
    TimeSeries.Aggregator.aggregate("time_series2", before_time: Beaker.Time.now + 5000, after_time: 0)
    TimeSeries.Aggregator.aggregate("time_series3", before_time: Beaker.Time.now + 5000, after_time: 0)

    response = get_response("/api/aggregated")
    |> doc

    assert response.status == 200

    decoded = Poison.decode!(response.resp_body)

    assert is_list Map.get(decoded, "time_series1")
  end
end
