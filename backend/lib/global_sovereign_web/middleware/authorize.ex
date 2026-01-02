defmodule GlobalSovereignWeb.Middleware.Authorize do
  @moduledoc """
  RBAC (Role-Based Access Control) middleware for GraphQL mutations.
  
  This middleware checks if the authenticated user has the required role
  to execute a mutation. Attach to mutations with:
  
    middleware(Authorize, roles: [:admin])
  """
  @behaviour Absinthe.Middleware

  def call(resolution, opts) do
    allowed_roles = Keyword.get(opts, :roles, [:admin]) |> Enum.map(&to_string/1)

    case resolution.context do
      %{current_user: user} when is_map(user) ->
        role = to_string(user.role)
        if role in allowed_roles do
          resolution
        else
          Absinthe.Resolution.put_result(resolution, {:error, "Insufficient permissions"})
        end

      _ ->
        Absinthe.Resolution.put_result(resolution, {:error, "Unauthenticated"})
    end
  end
end
