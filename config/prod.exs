use Mix.Config

config :distillery_example, ExampleWeb.Endpoint,
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  version: Application.spec(:distillery_example, :vsn)

config :distillery_example,
  ecto_repos: [Example.Repo],
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :logger,
  level: :info,
  handle_sasl_reports: true,
  handle_otp_reports: true
