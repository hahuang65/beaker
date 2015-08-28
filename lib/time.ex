defmodule Time do
  def now do
    {mega, sec, micro} = :os.timestamp()
    (mega * 1000000 + sec) * 1000000 + micro
  end
end
