defmodule Kubex.Mixfile do
  use Mix.Project

  def project do
    [app: :kubex,
     version: "0.1.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {KubexApp, []} ]
  end

  defp deps do
    [{:httpoison, "~> 0.6"},
     {:poison, "~> 1.4"},
     {:cowboy, "~> 1.0", only: :test},
     {:plug, "~> 0.13", only: :test}]
  end

  defp description do
    """
    Kubernetes integration for and in pure Elixir.
    """
  end

  defp package do
    [# These are the default files included in the package
     files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     contributors: ["Emil Ingerslev"],
     licenses: ["LGPLv3"],
     links: %{"GitHub" => "https://github.com/ingerslevio/kubex"}]
  end
end
