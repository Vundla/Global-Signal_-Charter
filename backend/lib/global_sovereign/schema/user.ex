defmodule GlobalSovereign.Schema.User do
  @moduledoc """
  User schema for authentication and authorization.
  
  Fields:
  - email: Unique email address for login
  - hashed_password: Bcrypt hashed password
  - role: :admin, :editor, or :viewer
  - is_active: Whether the user can login
  - created_at: Timestamp of user creation
  - updated_at: Timestamp of last update
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :hashed_password, :string
    field :password, :string, virtual: true
    field :role, Ecto.Enum, values: [:admin, :editor, :viewer], default: :viewer
    field :is_active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :role, :is_active])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> validate_email()
    |> validate_length(:password, min: 8, max: 100)
    |> hash_password()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: "must be a valid email")
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset
end
