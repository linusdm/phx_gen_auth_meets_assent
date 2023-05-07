defmodule MyApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MyApp.Repo

  alias MyApp.Accounts.{User, UserToken}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.token_query(token))
    :ok
  end

  def ensure_user(user_params) do
    changeset = %User{} |> User.changeset(user_params)
    email = Ecto.Changeset.fetch_field!(changeset, :email)

    # use he `:on_conflict` option to ensure the existing user is returened
    # see the ecto docs for the upsert functionallity:
    # https://hexdocs.pm/ecto/constraints-and-upserts.html#upserts
    Repo.insert!(changeset,
      on_conflict: [set: [email: email]],
      conflict_target: :email
    )
  end
end
