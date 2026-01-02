defmodule GlobalSovereignWeb.API.AuthControllerTest do
  use GlobalSovereignWeb.ConnCase, async: true

  alias GlobalSovereign.Accounts

  describe "POST /api/auth/register" do
    test "registers a new user with valid data", %{conn: conn} do
      params = %{
        "email" => "newuser@example.com",
        "password" => "securepassword123",
        "role" => "editor"
      }

      conn = post(conn, "/api/auth/register", params)

      assert %{
        "data" => %{
          "id" => _id,
          "email" => "newuser@example.com",
          "role" => "editor"
        },
        "token" => token
      } = json_response(conn, 201)

      assert is_binary(token)
      assert String.contains?(token, ".")
    end

    test "defaults to viewer role when not specified", %{conn: conn} do
      params = %{
        "email" => "viewer@example.com",
        "password" => "password123"
      }

      conn = post(conn, "/api/auth/register", params)

      assert %{"data" => %{"role" => "viewer"}} = json_response(conn, 201)
    end

    test "returns error with invalid email", %{conn: conn} do
      params = %{
        "email" => "notanemail",
        "password" => "password123"
      }

      conn = post(conn, "/api/auth/register", params)

      assert %{"error" => errors} = json_response(conn, 422)
      assert Map.has_key?(errors, "email")
    end

    test "returns error with short password", %{conn: conn} do
      params = %{
        "email" => "test@example.com",
        "password" => "short"
      }

      conn = post(conn, "/api/auth/register", params)

      assert %{"error" => errors} = json_response(conn, 422)
      assert Map.has_key?(errors, "password")
    end

    test "returns error when email already exists", %{conn: conn} do
      Accounts.create_user(%{
        email: "existing@example.com",
        password: "password123"
      })

      params = %{
        "email" => "existing@example.com",
        "password" => "anotherpassword"
      }

      conn = post(conn, "/api/auth/register", params)

      assert %{"error" => errors} = json_response(conn, 422)
      assert Map.has_key?(errors, "email")
    end
  end

  describe "POST /api/auth/login" do
    setup do
      {:ok, user} = Accounts.create_user(%{
        email: "login@example.com",
        password: "correctpassword",
        role: "admin"
      })

      %{user: user}
    end

    test "logs in with correct credentials", %{conn: conn, user: user} do
      params = %{
        "email" => "login@example.com",
        "password" => "correctpassword"
      }

      conn = post(conn, "/api/auth/login", params)

      assert %{
        "data" => %{
          "id" => id,
          "email" => "login@example.com",
          "role" => "admin"
        },
        "token" => token
      } = json_response(conn, 200)

      assert id == user.id
      assert is_binary(token)
    end

    test "rejects incorrect password", %{conn: conn} do
      params = %{
        "email" => "login@example.com",
        "password" => "wrongpassword"
      }

      conn = post(conn, "/api/auth/login", params)

      assert %{"error" => "Invalid email or password"} = json_response(conn, 401)
    end

    test "rejects non-existent email", %{conn: conn} do
      params = %{
        "email" => "nonexistent@example.com",
        "password" => "password123"
      }

      conn = post(conn, "/api/auth/login", params)

      assert %{"error" => "Invalid email or password"} = json_response(conn, 401)
    end
  end
end
