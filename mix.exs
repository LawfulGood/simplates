defmodule Simplates.Mixfile do
  use Mix.Project

  def project do
    [app: :simplates,
     version: "0.1.1",
     elixir: "~> 1.3",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     deps: deps(),
     name: "Simplates",
     docs: [extras: ["README.md"], main: "readme",
            source_ref: "v#{@version}",
            source_url: "https://github.com/LawfulGood/simplates"]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger,:mime]]
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
  defp deps do
    [
      {:mime, "~> 1.0.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:excoveralls, "~> 0.6", only: :test}
    ]
  end

  defp package do
    [# These are the default files included in the package
    name: :simplates,
    files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
    maintainers: ["Luke Strickland"],
    licenses: ["MIT"],
    links: %{"GitHub" => "https://github.com/LawfulGood/simplates"}]
  end
  
  defp description do
    """
    Simplates are a file format for server-side web programming.
    """
  end
end
