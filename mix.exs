defmodule EMage.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env == :prod,
      deps: deps(Mix.env)
    ]
  end

  defp deps(:test) do
    [] ++ deps(:prod)
  end
  defp deps(:dev) do
    [
      {:mix_test_watch, "~> 0.3"},
      {:dogma, "~> 0.1"},
      {:credo, "~> 0.4"},
      {:dialyxir, "~> 0.4", runtime: false}
    ] ++ deps(:prod)
  end
  defp deps(:prod) do
    [
      {:distillery, "~> 1.2"},
      {:edeliver, "~> 1.4.2"}
    ]
  end
end
