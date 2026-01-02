defmodule GlobalSovereignWeb.GraphQLTest do
  use GlobalSovereignWeb.ConnCase, async: true

  alias GlobalSovereign.Accounts
  alias GlobalSovereignWeb.Auth

  describe "GraphQL context/1" do
    test "extracts user from valid JWT token", %{conn: conn} do
      {:ok, user} = Accounts.create_user(%{
        email: "graphql@example.com",
        password: "password123",
        role: "admin"
      })

      {:ok, token, _claims} = Auth.generate_token(user)

      conn = conn
        |> put_req_header("authorization", "Bearer #{token}")

      context = GlobalSovereignWeb.GraphQL.context(conn)

      assert context.current_user.id == user.id
      assert context.current_user.email == user.email
    end

    test "returns empty context with no token", %{conn: conn} do
      context = GlobalSovereignWeb.GraphQL.context(conn)

      refute Map.has_key?(context, :current_user)
    end

    test "returns empty context with invalid token", %{conn: conn} do
      conn = conn
        |> put_req_header("authorization", "Bearer invalidtoken")

      context = GlobalSovereignWeb.GraphQL.context(conn)

      refute Map.has_key?(context, :current_user)
    end

    test "returns empty context with malformed header", %{conn: conn} do
      conn = conn
        |> put_req_header("authorization", "InvalidFormat")

      context = GlobalSovereignWeb.GraphQL.context(conn)

      refute Map.has_key?(context, :current_user)
    end
  end

  describe "GraphQL authenticated queries" do
    test "extracts current_user from token in authorization header", %{conn: conn} do
      {:ok, user} = Accounts.create_user(%{
        email: "query@example.com",
        password: "password123"
      })

      {:ok, token, _claims} = Auth.generate_token(user)

      conn = put_req_header(conn, "authorization", "Bearer #{token}")
      context = GlobalSovereignWeb.GraphQL.context(conn)

      assert context.current_user.id == user.id
    end
  end
end
