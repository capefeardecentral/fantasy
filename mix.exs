defmodule Fantasy.MixProject do
  use Mix.Project

  def project do
    [
      app: :fantasy,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:httpoison, "~> 1.8.0"},
      {:poison, "~> 3.1.0"},
      {:csv, "~> 3.0.0"},
      {:crawly, "~> 0.16.0"},
      {:floki, "~> 0.26.0"}
    ]
  end
end
