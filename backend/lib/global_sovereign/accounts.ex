defmodule GlobalSovereign.Accounts do
  @moduledoc """
  Accounts context for user management and authentication.
  
  Provides functions for:
  - Creating users
  - Authenticating users by email/password
  - Fetching users
  - Updating user roles
  """
  import Ecto.Query

  alias GlobalSovereign.Repo
  alias GlobalSovereign.Schema.User

  @doc """
  Get a user by ID.
  
  Returns {:ok, user} or {:error, :not_found}
  """
  def get_user(id) when is_binary(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Get a user by email.
  
  Returns the user struct or nil
  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Authenticate a user by email and password.
  
  Returns {:ok, user} if credentials are valid, {:error, :invalid_credentials} otherwise
  """
  def authenticate_user(email, password) when is_binary(email) and is_binary(password) do
    user = get_user_by_email(email)

    if user && Bcrypt.verify_pass(password, user.hashed_password) do
      {:ok, user}
    else
      {:error, :invalid_credentials}
    end
  end

  @doc """
  Create a new user.
  
  Returns {:ok, user} or {:error, changeset}
  """
  def create_user(attrs \\ {}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update a user.
  
  Returns {:ok, user} or {:error, changeset}
  """
  def update_user(user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  List all users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Get the count of users with a specific role.
  """
  def count_by_role(role) do
    Repo.one(from u in User, where: u.role == ^role, select: count(u.id))
  end
end
