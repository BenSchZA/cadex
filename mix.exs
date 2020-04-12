defmodule Cadex.MixProject do
  use Mix.Project

  def project do
    [
      app: :cadex,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :export],
      mod: {Cadex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:flow, "~> 1.0"},
      {:graphvix, "~> 1.0.0"},
      {:exprof, "~> 0.2.0"},
      {:stream_data, "~> 0.1", only: [:dev, :test, :prod]},
      {:decorator, "~> 1.3.2"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      # {:expyplot, "~> 1.1.2", only: [:dev, :test]},
      {:export, "~> 0.1.0"}
    ]
  end
end
