defmodule GlobalSovereignWeb.Middleware.AuthorizeTest do
  use GlobalSovereign.DataCase, async: true

  alias GlobalSovereignWeb.Middleware.Authorize
  alias Absinthe.Resolution

  describe "call/2" do
    test "allows request when user has required role" do
      user = %{id: "123", email: "admin@example.com", role: :admin}
      resolution = %Resolution{
        context: %{current_user: user},
        state: :unresolved
      }

      result = Authorize.call(resolution, roles: [:admin])

      assert result.state == :unresolved
    end

    test "allows request when user has one of multiple allowed roles" do
      user = %{id: "123", email: "editor@example.com", role: :editor}
      resolution = %Resolution{
        context: %{current_user: user},
        state: :unresolved
      }

      result = Authorize.call(resolution, roles: [:admin, :editor])

      assert result.state == :unresolved
    end

    test "denies request when user lacks required role" do
      user = %{id: "123", email: "viewer@example.com", role: :viewer}
      resolution = %Resolution{
        context: %{current_user: user},
        state: :unresolved
      }

      result = Authorize.call(resolution, roles: [:admin])

      assert result.state == :resolved
      assert ["Insufficient permissions"] = result.errors
    end

    test "denies request when no user in context" do
      resolution = %Resolution{
        context: %{},
        state: :unresolved
      }

      result = Authorize.call(resolution, roles: [:admin])

      assert result.state == :resolved
      assert ["Unauthenticated"] = result.errors
    end

    test "defaults to admin-only when no roles specified" do
      user = %{id: "123", email: "editor@example.com", role: :editor}
      resolution = %Resolution{
        context: %{current_user: user},
        state: :unresolved
      }

      result = Authorize.call(resolution, [])

      assert result.state == :resolved
      assert ["Insufficient permissions"] = result.errors
    end

    test "allows admin user with default roles" do
      user = %{id: "123", email: "admin@example.com", role: :admin}
      resolution = %Resolution{
        context: %{current_user: user},
        state: :unresolved
      }

      result = Authorize.call(resolution, [])

      assert result.state == :unresolved
    end
  end
end
