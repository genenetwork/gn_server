defmodule GnServer.Mixfile do
  use Mix.Project

  def project do
    [app: :gn_server,
     version: "0.0.1",
     # elixir: "~> 1.2.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :cachex, :maru, :mariaex, :ecto],
     mod: {GnServer,[]}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  def deps do
  [ {:maru, "~> 0.9.5"} ,
    {:mysqlex, github: "tjheeta/mysqlex" },
    {:ecto, "~> 2.0.2"},
    {:mariaex, "~> 0.7.3"},
    {:cors_plug, "~> 1.1"},
    {:cachex, "~> 1.2.1"},
    {:gn_exec, "~> 0.1.0", path: "../gn_exec/"}]
  end
end
