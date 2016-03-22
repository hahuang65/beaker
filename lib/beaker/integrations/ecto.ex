defmodule Beaker.Integrations.Ecto do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      defoverridable [__log__: 1]
      def __log__(entry) do
        if entry.query_time, do: Beaker.TimeSeries.sample("Ecto:QueryTime", entry.query_time / 1000)
        if entry.queue_time, do: Beaker.TimeSeries.sample("Ecto:QueueTime", entry.queue_time / 1000)
        Beaker.Counter.incr("Ecto:Queries")

        super(entry)
      end
    end
  end
end
