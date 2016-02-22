defmodule Beaker.Integrations.PhoenixTest do
  use ExUnit.Case
  use Plug.Test

  import Plug.Conn

  setup do
    on_exit fn ->
      Beaker.Counter.clear
    end
  end

  test "Increments counter outside beaker" do
    before_count = Beaker.Counter.get("Phoenix:Requests")
    conn = conn(:get, "/stuff")
    Beaker.Integrations.Phoenix.call(conn, %{})
    |> Plug.Conn.resp(200, "hello")
    |> Plug.Conn.send_resp

    after_count = Beaker.Counter.get("Phoenix:Requests")

    assert before_count != after_count 
  end

  test "Skips for /beaker routes" do
    before_count = Beaker.Counter.get("Phoenix:Requests")

    conn(:get, "/beaker/api/counters")
    |> TestPipe.call([])
    |> Plug.Conn.send_resp(200, "OK")

    after_count = Beaker.Counter.get("Phoenix:Requests")

    assert before_count == after_count 
  end

  test "Can customize the skip path" do
    before_count = Beaker.Counter.get("Phoenix:Requests")

    conn(:get, "/not_beaker")
    |> TestPipeWithPath.call([])
    |> Plug.Conn.send_resp(200, "OK")

    after_count = Beaker.Counter.get("Phoenix:Requests")

    assert before_count == after_count 
  end
end

defmodule TestPipe do
  use Plug.Builder

  plug Beaker.Integrations.Phoenix

end

defmodule TestPipeWithPath do
  use Plug.Builder

  plug Beaker.Integrations.Phoenix, ignore_path: "not_beaker"
end
