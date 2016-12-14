defmodule Beaker.Mixfile do
  use Mix.Project

  def project do
    [
      app: :beaker,
      version: "1.2.0",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: compilers(Mix.env),
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
    [
      applications: apps(Mix.env),
      mod: {Beaker, []}
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp apps(_), do: apps
  defp apps do
    [:logger]
  end

  # Need phoenix compiler to compile our views.
  defp compilers(:test) do
    [:phoenix | compilers]
  end
  defp compilers(_) do
    if Code.ensure_loaded?(Phoenix.HTML) do
      [:phoenix | compilers]
    else
      compilers
    end
  end
  defp compilers do
    Mix.compilers
  end

  defp deps do
    [
      {:bureaucrat, "~> 0.1.4"},
      {:earmark, "~> 1.0.3", only: :dev},
      {:ecto, "~> 2.0", optional: true},
      {:ex_doc, "~> 0.14", only: :dev},
      {:inch_ex, "~> 0.5", only: :dev},
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:phoenix, "~> 1.2.1", optional: true},
      {:phoenix_ecto, "~> 3.0", only: :test},
      {:phoenix_html, "~> 2.6", only: :test},
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
      maintainers: ["Howard Huang", "Martin Feckie"],
      licenses: [],
      links: %{
        "GitHub" => "http://github.com/hahuang65/beaker",
        "Docs" => "http://hexdocs.pm/beaker/"
      }
    ]
  end
end
