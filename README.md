# Distillery AWS Example App

This application is intended to be used with the AWS guide in the Distillery documentation.

## Running Locally

You need to have PostgreSQL installed locally. Adjust the configuration as needed.

- `mix do deps.get, compile`
- `mix ecto.create`
- `mix ecto.migrate`
- `mix phx.server`

You can then open the app at `https://localhost:4000`

## License

This project is licensed under Apache 2
