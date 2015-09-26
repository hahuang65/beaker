if Code.ensure_loaded?(Phoenix.Endpoint) do
  defmodule Beaker.Integrations.Phoenix do
    @moduledoc false
    @behaviour Plug
    import Plug.Conn, only: [register_before_send: 2]

    def init(opts), do: opts

    def call(conn, _opts) do
      start_time = Beaker.Time.now

      register_before_send(conn, fn(conn) ->
        end_time = Beaker.Time.now
        diff = end_time - start_time

        Beaker.TimeSeries.sample("Phoenix:ResponseTime", diff / 1000)
        Beaker.Counter.incr("Phoenix:Requests")

        conn
      end)
    end
  end
end
