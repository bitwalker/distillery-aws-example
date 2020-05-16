defmodule Example.Todo do
  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__meta__]}

  schema "todos" do
    field :title, :string
    field :completed, :boolean

    timestamps()
  end

  @doc """
  Creates a Todo in the database 
  """
  def create(%Ecto.Changeset{} = changeset) do
    result = Example.Repo.insert(changeset)
    case result do
      {:ok, todo} ->
        {:ok, to_result(todo)}
      {:error, cs} ->
        to_error(cs)
    end
  end

  @doc """
  Updates a Todo in the database 
  """
  def update(id, params) do
    result =
      Example.Repo.get(__MODULE__, id)
      |> changeset(params)
      |> Example.Repo.update()
    case result do
      {:ok, todo} ->
        {:ok, to_result(todo)}
      {:error, cs} ->
        to_error(cs)
    end
  end

  @doc """
  Deletes a Todo with the given id
  """
  def delete(id) do
    with %__MODULE__{} = todo <- Example.Repo.get(__MODULE__, id),
         {:ok, _} <- Example.Repo.delete(todo) do
      :ok
    else
      nil ->
        :ok
      {:error, cs} ->
        to_error(cs)
    end
  end

  @doc """
  Deletes all Todos
  """
  def delete_all() do
    Example.Repo.delete_all(__MODULE__)
    :ok
  rescue
    err in [Ecto.QueryError] ->
      {:error, Exception.message(err)}
  end

  @doc """
  Returns all Todos from the database
  """
  def all() do 
    todos =
      Example.Repo.all(__MODULE__)
      |> Enum.map(&to_result/1)
    {:ok, todos}
  rescue
    err in [Ecto.QueryError] ->
      {:error, Exception.message(err)}
  end

  @doc """
  Applies a set of parameters to a Todo struct, validating them,
  the result is an Ecto.Changeset
  """
  def changeset(%__MODULE__{} = todo, params \\ %{}) do
    todo
    |> Ecto.Changeset.cast(params, [:title, :completed])
    |> Ecto.Changeset.validate_required([:title])
  end

  defp to_error(%Ecto.Changeset{} = cs) do
    errs =
      Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
    {:error, errs}
  end

  defp to_result(%__MODULE__{} = result) do
    # Strip Ecto metadata
    result
    |> Map.delete(:__meta__)
  end
end
