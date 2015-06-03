defmodule Beaker do
  use Application

  @doc """
  Starts the Beaker app.

  This will start all submodules under supervision:
    * Beaker.Counter
    * Beaker.Gauge

  """
  def start do
    import Supervisor.Spec

    children = [
      worker(Beaker.Counter, []),
      worker(Beaker.Gauge, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
