Beaker
======

[![Build Status](https://travis-ci.org/hahuang65/beaker.svg?branch=master)](https://travis-ci.org/hahuang65/beaker)
[![Inline docs](http://inch-ci.org/github/hahuang65/beaker.svg?branch=master&style=shields)](http://inch-ci.org/github/hahuang65/beaker)

Beaker is a tool that can be used to keep track of metrics for your Elixir project. It aims to provide an easy way to register statistics as well as an easy way to visualize them.

Note: Beaker metrics are currently ephemeral and are scoped to the app (or more specifically Beaker) being stopped. Metrics are not persisted across restarts.

For more information, see the [online documentation](http://hexdocs.pm/beaker).

## Usage

To include Beaker in your application, add it to your `mix.exs` file:

```elixir
defp deps do
  [
    {:beaker, ">= 0.0.2"}
  ]
```

And add it to the list of applications started with yours:

```elixir
def application do
  [applications: [:beaker]]
end
```

## Metrics

Beaker provides a variety of different metric types:

### Gauge

The gauge is a simple gauge. It's a metric where a value can be set and retrieved.

It is commonly used for metrics that return a single value.
Examples are:
  * Average response time
  * Uptime (Availability)
  * Latency / Ping

You can set and retrieve the value of a gauge like so:

```elixir
iex> Beaker.Gauge.set("foo", 50)
:ok

iex> Beaker.Gauge.get("foo")
50
```

Sometimes you'll want to time something, and set that duration to a gauge. We provide a convenience for that.

```elixir
iex> Beaker.Gauge.time("foo", fn -> 2 + 2 end)
4
```

```elixir
# Or if you prefer `do` syntax:
Beaker.Gauge.time("foo") do
  2 + 2
end
6
```

You can get all of your gauges in the form of a map if you need:

```elixir
iex> Beaker.Gauge.all
%{"foo" => 10, "bar" => 45}
```

You can remove all your gauges and start from scratch:

```elixir
iex> Beaker.Gauge.clear
:ok
```

### Counter

The counter is a signed bi-directional integer counter. It can keep track of integers and increment and decrement them.

It is commonly used for metrics that keep track of some cumulative value.
Examples are:
  * Total number of downloads
  * Number of queued jobs
  * Quotas

You can set and retrieve the value of a counter like so:

```elixir
iex> Beaker.Counter.set("foo", 10)
:ok

iex> Beaker.Counter.get("foo")
10
```

You can also use a counter more traditionally, via incrementing and decrementing:

```elixir
iex> Beaker.Counter.incr("foo")
:ok

iex> Beaker.Counter.get("foo")
11


iex> Beaker.Counter.decr("foo")
:ok

iex> Beaker.Counter.get("foo")
10
```

If incrementing and decrementing by 1 is not a big enough step for you:

```elixir
iex> Beaker.Counter.incr_by("foo", 5)
:ok

iex> Beaker.Counter.get("foo")
15

iex> Beaker.Counter.decr_by("foo", 10)
:ok

iex> Beaker.Counter.get("foo")
5
```

You can get all of your counters in the form of a map if you need:

```elixir
iex> Beaker.Counter.all
%{"foo" => 10, "bar" => 45}
```

You can remove all your counters and start from scratch:

```elixir
iex> Beaker.Counter.clear
:ok
```

### Time Series

The time series is basically a series of values with a time (epoch) attached to each value at the time the value was recorded.

It is commonly used to keep track of the change in value of some metric across a period of time.
Examples are:
  * Response time across a period of time
  * Error rates across a period of time
  * Download count across a period of time

To sample (record a value) a time series:

```elixir
iex> Beaker.TimeSeries.sample("foo", 50)
:ok
iex> Beaker.TimeSeries.sample("foo", 66)
:ok
iex> Beaker.TimeSeries.sample("foo", 30)
:ok
iex> Beaker.TimeSeries.sample("bar", 10)
:ok
iex> Beaker.TimeSeries.sample("bar", 50)
:ok
```

Sometimes you'll want to time something, and sample that duration to a time series. We provide a convenience for that.

```elixir
iex> Beaker.TimeSeries.time("baz", fn -> 2 + 2 end)
4
```

```elixir
# Or if you prefer `do` block syntax:
Beaker.TimeSeries.time("baz") do
  2 + 2
end
```

Anytime a time series is retrieved, it will be in the format of a list of pairs.
Each pair consists of a timestamp in epoch and the value sampled, i.e. `{timestamp, value}`.
The list will be guaranteed to be in reverse chronological order, that is, the latest sample will be the first in the list.

To get the time series that have been recorded for a key:

```elixir
iex> Beaker.TimeSeries.get("foo")
[{1434738115306786, 30}, {1434738112851607, 66}, {1434738107132294, 50}]
```

To retrieve all time series:

```elixir
iex> Beaker.TimeSeries.all
%{"bar" => [{1434738203344586, 50}, {1434738201507329, 10}],
  "foo" => [{1434738115306786, 32}, {1434738112851607, 87}, {1434738107132294, 50}]}
```

And to clear all time series:

```elixir
iex> Beaker.TimeSeries.clear
:ok
```

## Important Links

  * [Documentation](http://hexdocs.pm/beaker)
