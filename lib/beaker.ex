defmodule Beaker do
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Beaker.Counter, []),
      worker(Beaker.Gauge, []),
      worker(Beaker.TimeSeries, []),
      worker(Beaker.TimeSeries.Aggregated, []),
      worker(Beaker.TimeSeries.Aggregator, []),
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
