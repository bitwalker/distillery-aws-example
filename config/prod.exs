use Mix.Config

config :distillery_example, ExampleWeb.Endpoint,
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  version: Application.spec(:distillery_example, :vsn)

config :distillery_example, Example.Repo,
  adapter: Ecto.Adapters.Postgres

config :logger, level: :info
