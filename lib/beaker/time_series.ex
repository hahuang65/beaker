defmodule Beaker.TimeSeries do
  use GenServer

  ## Client API

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :beaker_time_series)
  end

  def all do
    GenServer.call(:beaker_time_series, :all)
  end

  def clear do
    GenServer.cast(:beaker_time_series, :clear)
  end

  def get(key) do
    GenServer.call(:beaker_time_series, {:get, key})
  end

  def sample(key, value) do
    GenServer.cast(:beaker_time_series, {:sample, key, value})
  end

  defp now_in_epoch do
    {mega, sec, micro} = :os.timestamp()
    (mega * 1000000 + sec) * 1000000 + micro
  end

  ## Server Callbacks

  @doc false
  def init(:ok) do
    {:ok, HashDict.new}
  end

  @doc false
  def handle_call(:all, _from, time_series) do
    {:reply, Enum.into(time_series, %{}), time_series}
  end

  @doc false
  def handle_call({:get, key}, _from, time_series) do
    {:reply, HashDict.get(time_series, key), time_series}
  end

  @doc false
  def handle_cast(:clear, _time_series) do
    {:noreply, HashDict.new}
  end

  @doc false
  def handle_cast({:sample, key, value}, time_series) do
    entry = {now_in_epoch(), value}
    {:noreply, HashDict.update(time_series, key, [entry], fn(list) -> [entry | list] end)}
  end

end
