defmodule GlobalSovereignWeb.GraphQL do
  @moduledoc """
  GraphQL context and helper functions.
  
  Attaches the current_user to the Absinthe context from JWT tokens.
  """

  def context(conn) do
    context = %{}

    # Try to extract JWT token from Authorization header
    case extract_token(conn) do
      {:ok, token} ->
        case GlobalSovereignWeb.Auth.verify_token(token) do
          {:ok, claims} ->
            case GlobalSovereign.Accounts.get_user(claims["sub"]) do
              {:ok, user} -> Map.put(context, :current_user, user)
              _ -> context
            end

          _ ->
            context
        end

      :error ->
        context
    end
  end

  defp extract_token(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      [auth_header] ->
        case String.split(auth_header, " ") do
          [_bearer, token] -> {:ok, token}
          _ -> :error
        end

      _ ->
        :error
    end
  end
end
