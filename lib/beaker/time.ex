defmodule Beaker.Time do
  @moduledoc false

  def now do
    :os.system_time(:micro_seconds)
  end

  def last_full_minute do
    now = Beaker.Time.now
    remainder = rem(now, 60000000)

    now - remainder
  end

  def to_gmt(epoch_timestamp) do
    :erlang.convert_time_unit(epoch_timestamp, :micro_seconds, :milli_seconds)
    |> :calendar.gregorian_seconds_to_datetime
  end
end
