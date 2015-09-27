if Code.ensure_loaded?(Ecto.Repo) do
  defmodule Beaker.Integrations.Ecto do
    @moduledoc false

    defmacro __using__(_opts) do
      quote do
        def log(entry) do
          Beaker.TimeSeries.sample("Ecto:QueryTime", entry.query_time / 1000)
          Beaker.TimeSeries.sample("Ecto:QueueTime", entry.queue_time / 1000)
          Beaker.Counter.incr("Ecto:Queries")

          super(entry)
        end

        defoverridable [log: 1]
      end
    end
  end
end
