defmodule Beaker.Time do
  @moduledoc false

  def now do
    {mega, sec, micro} = :os.timestamp()
    (mega * 1000000 + sec) * 1000000 + micro
  end

  def last_full_minute do
    now = Beaker.Time.now
    remainder = rem(now, 60000000)

    now - remainder
  end
end
