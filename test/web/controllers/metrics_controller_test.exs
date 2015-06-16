defmodule Beaker.Web.MetricsControllerTest do
  use TestApp.Case, async: true

  test "/metrics displays all counters and their values" do
    Beaker.Counter.set("counter1", 33)
    Beaker.Counter.incr("counter2")

    response = conn(:get, "/metrics") |> send_request

    assert String.contains?(response.resp_body, "Counters")
    assert String.contains?(response.resp_body, "counter1: 33")
    assert String.contains?(response.resp_body, "counter2: 1")
  end

  test "/metrics displays all gauges and their values" do
    Beaker.Gauge.set("gauges1", 66)
    Beaker.Gauge.set("gauges2", 99)

    response = conn(:get, "/metrics") |> send_request

    assert String.contains?(response.resp_body, "Gauges")
    assert String.contains?(response.resp_body, "gauges1: 66")
    assert String.contains?(response.resp_body, "gauges2: 99")
  end
end
