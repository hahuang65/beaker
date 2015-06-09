defmodule Beaker.Mixfile do
  use Mix.Project

  def project do
    [
      app: :beaker,
      version: "0.0.1",
      elixir: "~> 1.0",
      name: "beaker",
      description: description,
      package: package,
      source_url: "https://github.com/hahuang65/beaker",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:earmark, "~> 0.1", only: :docs},
      {:ex_doc, "~> 0.7", only: :docs},
      {:inch_ex, only: :docs}
    ]
  end

  defp description do
    """
    Measure your Elixir!

    A metrics library that will help Elixirists keep track of their application's performance, as well as any custom statistics they like.
    """
  end

  defp package do
    [
      contributors: ["Howard Huang"],
      links: %{
        "GitHub" => "http://github.com/hahuang65/beaker",
        "Docs" => "http://hexdocs.pm/beaker/"
      }
    ]
  end
end
