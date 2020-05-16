defmodule BinaryFoodsDb.MixProject do
  use Mix.Project

  def project do
    [
      app: :binary_foods_db,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {BinaryFoodsDb.Application, []}
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.0"},
      {:plug, "~> 1.6"},
      {:cowboy, "~> 2.4"},
      {:ecto, "~> 2.1"},
      {:credo, "~> 0.10", except: :prod, runtime: false}
    ]
  end
end
