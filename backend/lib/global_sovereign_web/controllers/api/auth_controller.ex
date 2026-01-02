defmodule GlobalSovereignWeb.API.AuthController do
  @moduledoc """
  Authentication controller for user login and registration.
  """
  use GlobalSovereignWeb, :controller

  alias GlobalSovereign.Accounts

  @doc """
  POST /api/auth/register
  
  Create a new user account.
  """
  def register(conn, %{"email" => email, "password" => password} = params) do
    case Accounts.create_user(%{
      email: email,
      password: password,
      role: Map.get(params, "role", "viewer")
    }) do
      {:ok, user} ->
        {:ok, token, _claims} = GlobalSovereignWeb.Auth.generate_token(user)

        conn
        |> put_status(:created)
        |> json(%{
          data: %{
            id: user.id,
            email: user.email,
            role: user.role
          },
          token: token
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: format_errors(changeset)})
    end
  end

  @doc """
  POST /api/auth/login
  
  Authenticate a user with email and password.
  """
  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = GlobalSovereignWeb.Auth.generate_token(user)

        conn
        |> json(%{
          data: %{
            id: user.id,
            email: user.email,
            role: user.role
          },
          token: token
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
