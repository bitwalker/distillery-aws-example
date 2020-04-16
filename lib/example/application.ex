defmodule Example.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children =
    [
      supervisor(Example.Database, []),
      supervisor(ExampleWeb.Endpoint, [])
    ] ++
      case Application.get_env(:libcluster, :topologies) do
        nil -> []
        topologies -> [{Cluster.Supervisor, [topologies, [name: Example.ClusterSupervisor]]}]
      end

    opts = [strategy: :one_for_one, name: Example.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
