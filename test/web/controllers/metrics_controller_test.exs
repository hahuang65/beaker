defmodule Beaker.Web.MetricsControllerTest do
  use TestApp.Case, async: true

  test "/metrics displays all counters and their values" do
    Beaker.Counter.set("counter1", 33)
    Beaker.Counter.incr("counter2")

    response = conn(:get, "/metrics") |> send_request

    assert String.contains?(response.resp_body, "Counters")
    assert String.contains?(response.resp_body, "counter1")
    assert String.contains?(response.resp_body, "33")
    assert String.contains?(response.resp_body, "counter2")
    assert String.contains?(response.resp_body, "1")
  end

  test "/metrics displays all gauges and their values" do
    Beaker.Gauge.set("gauges1", 66)
    Beaker.Gauge.set("gauges2", 99)

    response = conn(:get, "/metrics") |> send_request

    assert String.contains?(response.resp_body, "Gauges")
    assert String.contains?(response.resp_body, "gauges1")
    assert String.contains?(response.resp_body, "66")
    assert String.contains?(response.resp_body, "gauges2")
    assert String.contains?(response.resp_body, "99")
  end

  test "/metrics creates a div for each time series" do
    Beaker.TimeSeries.sample("time_series1", 10)
    Beaker.TimeSeries.sample("time_series2", 20)
    Beaker.TimeSeries.sample("time_series3", 30)

    Beaker.TimeSeries.Aggregator.aggregate("time_series1", before_time: Beaker.Time.now + 5000, after_time: 0)
    Beaker.TimeSeries.Aggregator.aggregate("time_series2", before_time: Beaker.Time.now + 5000, after_time: 0)
    Beaker.TimeSeries.Aggregator.aggregate("time_series3", before_time: Beaker.Time.now + 5000, after_time: 0)

    response = conn(:get, "/metrics") |> send_request

    assert String.contains?(response.resp_body, "time_series1")
    assert String.contains?(response.resp_body, "10")
    assert String.contains?(response.resp_body, "time_series2")
    assert String.contains?(response.resp_body, "20")
    assert String.contains?(response.resp_body, "time_series3")
    assert String.contains?(response.resp_body, "30")
  end
end
