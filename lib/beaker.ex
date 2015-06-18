defmodule Beaker do
  @moduledoc """
  `Beaker` is the parent application that will start all the different `Beaker` metric applications.
  """

  use Application

  @doc """
  Starts the Beaker app.

  This will start all submodules under supervision:
    * Beaker.Counter
    * Beaker.Gauge

  ## Examples

      Beaker.start()

  """
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Beaker.Counter, []),
      worker(Beaker.Gauge, []),
      worker(Beaker.TimeSeries, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
