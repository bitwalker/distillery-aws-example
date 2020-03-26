defmodule Example.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children =
      [
        supervisor(Example.Database, []),
        supervisor(ExampleWeb.Endpoint, [])
      ] ++ libcluster()

    opts = [strategy: :one_for_one, name: Example.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp libcluster(topologies \\ Application.get_env(:libcluster, :topologies))

  defp libcluster(nil), do: []

  defp libcluster(topologies) do
    [{Cluster.Supervisor, [topologies, [name: Example.ClusterSupervisor]]}]
  end
end
