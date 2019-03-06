use Mix.Config

# Application name
app = System.get_env("APPLICATION_NAME")
env = System.get_env("ENVIRONMENT_NAME")
region = System.get_env("AWS_REGION")

# Locate awscli
aws = System.find_executable("aws")

cond do
  is_nil(app) ->
    raise "APPLICATION_NAME is unset!"
  is_nil(env) ->
    raise "ENVIRONMENT_NAME is unset!"
  is_nil(aws) ->
    raise "Unable to find `aws` executable!"
  :else ->
    :ok
end

# Pull database password from SSM
db_secret_name = "/#{app}/#{env}/database/password"
db_password =
  case System.cmd(aws, ["ssm", "get-parameter", "--region=#{region}", "--name=#{db_secret_name}", "--with-decryption"]) do
    {json, 0} ->
      %{"Parameter" => %{"Value" => password}} = Jason.decode!(json)
      password
    {output, status} ->
      raise "Unable to get database password, command exited with status #{status}:\n#{output}"
  end

config :distillery_example, Example.Repo,
  username: System.get_env("DATABASE_USER"),
  password: db_password,
  database: System.get_env("DATABASE_NAME"),
  hostname: System.get_env("DATABASE_HOST"),
  pool_size: 15

# Set configuration for Phoenix endpoint
config :distillery_example, ExampleWeb.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  root: ".",
  secret_key_base: "u1QXlca4XEZKb1o3HL/aUlznI1qstCNAQ6yme/lFbFIs0Iqiq/annZ+Ty8JyUCDc"

config :libcluster,
  topologies: [
    example: [
      strategy: ClusterEC2.Strategy.Tags,
      ec2_tagname: "Name",
      ec2_tagvalue: "#{app}-#{env}",
      app_prefix: "distillery_example"
    ]
  ]

