defmodule GlobalSovereign.AccountsTest do
  use GlobalSovereign.DataCase, async: true

  alias GlobalSovereign.Accounts
  alias GlobalSovereign.Schema.User

  describe "create_user/1" do
    test "creates user with valid attributes" do
      attrs = %{
        email: "newuser@example.com",
        password: "securepassword123",
        role: "editor"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(attrs)
      assert user.email == "newuser@example.com"
      assert user.role == :editor
      assert user.hashed_password != "securepassword123"
      assert Bcrypt.verify_pass("securepassword123", user.hashed_password)
    end

    test "defaults to viewer role" do
      attrs = %{
        email: "viewer@example.com",
        password: "password123"
      }

      assert {:ok, user} = Accounts.create_user(attrs)
      assert user.role == :viewer
    end

    test "requires email" do
      attrs = %{password: "password123"}
      assert {:error, changeset} = Accounts.create_user(attrs)
      assert "can't be blank" in errors_on(changeset).email
    end

    test "requires password" do
      attrs = %{email: "test@example.com"}
      assert {:error, changeset} = Accounts.create_user(attrs)
      assert "can't be blank" in errors_on(changeset).password
    end

    test "validates email format" do
      attrs = %{email: "notanemail", password: "password123"}
      assert {:error, changeset} = Accounts.create_user(attrs)
      assert "must be a valid email" in errors_on(changeset).email
    end

    test "enforces unique email" do
      email = "unique@example.com"
      attrs = %{email: email, password: "password123"}

      assert {:ok, _user} = Accounts.create_user(attrs)
      assert {:error, changeset} = Accounts.create_user(attrs)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates password length" do
      attrs = %{email: "test@example.com", password: "short"}
      assert {:error, changeset} = Accounts.create_user(attrs)
      assert "should be at least 8 character(s)" in errors_on(changeset).password
    end
  end

  describe "get_user/1" do
    test "returns user when found" do
      {:ok, created_user} = Accounts.create_user(%{
        email: "found@example.com",
        password: "password123"
      })

      assert {:ok, user} = Accounts.get_user(created_user.id)
      assert user.id == created_user.id
      assert user.email == "found@example.com"
    end

    test "returns error when not found" do
      assert {:error, :not_found} = Accounts.get_user("00000000-0000-0000-0000-000000000000")
    end
  end

  describe "authenticate_user/2" do
    setup do
      {:ok, user} = Accounts.create_user(%{
        email: "auth@example.com",
        password: "correctpassword",
        role: "admin"
      })

      %{user: user}
    end

    test "authenticates with correct credentials", %{user: user} do
      assert {:ok, authenticated_user} = Accounts.authenticate_user("auth@example.com", "correctpassword")
      assert authenticated_user.id == user.id
      assert authenticated_user.email == user.email
    end

    test "rejects incorrect password" do
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("auth@example.com", "wrongpassword")
    end

    test "rejects non-existent email" do
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("nonexistent@example.com", "password")
    end
  end

  describe "list_users/0" do
    test "returns all users" do
      Accounts.create_user(%{email: "user1@example.com", password: "password123"})
      Accounts.create_user(%{email: "user2@example.com", password: "password123"})

      users = Accounts.list_users()
      assert length(users) >= 2
      assert Enum.any?(users, fn u -> u.email == "user1@example.com" end)
      assert Enum.any?(users, fn u -> u.email == "user2@example.com" end)
    end
  end

  describe "count_by_role/1" do
    test "counts users by role" do
      Accounts.create_user(%{email: "admin1@example.com", password: "password123", role: "admin"})
      Accounts.create_user(%{email: "admin2@example.com", password: "password123", role: "admin"})
      Accounts.create_user(%{email: "viewer@example.com", password: "password123", role: "viewer"})

      admin_count = Accounts.count_by_role(:admin)
      viewer_count = Accounts.count_by_role(:viewer)

      assert admin_count >= 2
      assert viewer_count >= 1
    end
  end
end
