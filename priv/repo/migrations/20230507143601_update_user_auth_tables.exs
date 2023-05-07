defmodule MyApp.Repo.Migrations.UpdateUserAuthTables do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :hashed_password, :string, null: false
      remove :confirmed_at, :naive_datetime
    end

    drop unique_index(:users_tokens, [:context, :token])

    alter table(:users_tokens) do
      remove :context, :string, null: false
      remove :sent_to, :string
    end

    create unique_index(:users_tokens, [:token])
  end
end
