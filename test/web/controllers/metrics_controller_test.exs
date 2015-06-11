defmodule Beaker.Web.MetricsControllerTest do
  use TestApp.Case, async: true

  test "/metrics returns Hello World" do
    response = conn(:get, "/metrics") |> send_request
    assert String.contains?(response.resp_body, "Hello World")
  end
end
