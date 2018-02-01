defmodule EMage.Web.Mixfile do
  use Mix.Project

  def project do
    [
      app: :emage_web,
      version: "0.0.2",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {EMage.Web.Application, []},
      extra_applications: [:logger, :runtime_tools, :emage]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:gettext, "~> 0.14"},
      {:cowboy, "~> 1.1"},
      {:emage, in_umbrella: true},
      {:phoenix_live_reload, "~> 1.1", only: :dev}
    ]
  end

  defp aliases do
    []
  end
end
