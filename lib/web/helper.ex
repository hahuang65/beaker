defmodule Beaker.Web.Helper do
  @moduledoc false

  @colors ~w(yellow orange red magenta violet blue cyan green)

  def random_color do
    :random.seed(:os.timestamp)

    @colors
    |> Enum.shuffle
    |> hd
  end
end
