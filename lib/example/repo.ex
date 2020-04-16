defmodule Example.Repo do
  use Ecto.Repo, otp_app: :distillery_example,
  adapter: Ecto.Adapters.Postgres

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    opts =
      opts
      |> Keyword.put(:url, System.get_env("DATABASE_URL"))
      |> Keyword.put(:hostname, System.get_env("DATABASE_HOST"))
    {:ok, opts}
  end
end
