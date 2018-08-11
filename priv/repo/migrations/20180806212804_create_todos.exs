defmodule Example.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :completed, :boolean

      timestamps(type: :naive_datetime)
    end
  end
end
