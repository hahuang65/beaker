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
    {:beaker, ">= 0.0.0"}
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

## Important Links

  * [Documentation](http://hexdocs.pm/beaker)
