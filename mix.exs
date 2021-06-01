defmodule Attributes.MixProject do
  use Mix.Project

  @github "https://github.com/danielefongo/attributes"
  @version "0.1.0"

  def project do
    [
      app: :attributes,
      description: "Set and get complex attributes on modules",
      source_url: @github,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: [
        links: %{"GitHub" => @github},
        licenses: ["GPL-3.0-or-later"]
      ],
      docs: [
        main: "readme",
        extras: ["README.md", "changelog.md", "LICENSE"],
        source_ref: "v#{@version}",
        source_url: @github
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.4.1", only: [:dev, :test]},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp aliases do
    [
      "format.all": [
        "format mix.exs 'lib/**/*.{ex,exs}' 'test/**/*.{ex,exs}' 'config/*.{ex,exs}'"
      ],
      "format.check": [
        "format --check-formatted mix.exs 'lib/**/*.{ex,exs}' 'test/**/*.{ex,exs}' 'config/*.{ex, exs}'"
      ],
      check: [
        "compile --all-warnings --ignore-module-conflict --warnings-as-errors --debug-info",
        "format.check",
        "credo"
      ]
    ]
  end
end
