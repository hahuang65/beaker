defmodule Beaker do
  use Application

  def start do
    import Supervisor.Spec

    children = [
      worker(Beaker.Counter, []),
      worker(Beaker.Gauge, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
