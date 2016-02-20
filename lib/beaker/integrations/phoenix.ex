defmodule Beaker.Integrations.Phoenix do
  @moduledoc """
  A Plug for adding Beaker stats to your Phoenix pipeline(s)

  plug Beaker.Integrations.Phoenix

  or

  plug Beaker.Integrations.Phoenix, ignore_path: "my_special_path"

  ## Options
    * `:ignore_path` - The top level of the URL to ignore, default is "beaker".

  """
  @behaviour Plug
  import Plug.Conn

  def init(opts) do
    Keyword.get(opts, :ignore_path, "beaker")
  end

  def call(conn, ignore_path) do

    if hd(conn.path_info) == ignore_path do
      conn
    else
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
