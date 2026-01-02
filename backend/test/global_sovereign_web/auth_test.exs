defmodule GlobalSovereignWeb.AuthTest do
  use GlobalSovereign.DataCase, async: true

  alias GlobalSovereignWeb.Auth
  alias GlobalSovereign.Accounts

  describe "generate_token/1" do
    test "creates valid JWT token with user claims" do
      user = %{
        id: "123e4567-e89b-12d3-a456-426614174000",
        email: "test@example.com",
        role: :admin
      }

      {:ok, token, claims} = Auth.generate_token(user)

      assert is_binary(token)
      assert String.contains?(token, ".")
      assert claims["sub"] == user.id
      assert claims["email"] == user.email
      assert claims["role"] == "admin"
      assert claims["exp"] > System.os_time(:second)
    end

    test "token expires in 7 days" do
      user = %{
        id: "123e4567-e89b-12d3-a456-426614174000",
        email: "test@example.com",
        role: :viewer
      }

      {:ok, _token, claims} = Auth.generate_token(user)

      expected_exp = System.os_time(:second) + 604800  # 7 days
      assert_in_delta claims["exp"], expected_exp, 5
    end
  end

  describe "verify_token/1" do
    test "verifies valid token" do
      user = %{
        id: "123e4567-e89b-12d3-a456-426614174000",
        email: "test@example.com",
        role: :editor
      }

      {:ok, token, _claims} = Auth.generate_token(user)
      {:ok, verified_claims} = Auth.verify_token(token)

      assert verified_claims["sub"] == user.id
      assert verified_claims["email"] == user.email
      assert verified_claims["role"] == "editor"
    end

    test "rejects invalid token" do
      assert {:error, :invalid_token} = Auth.verify_token("invalid.token.here")
    end

    test "rejects expired token" do
      # Create token with past expiration
      claims = %{
        "sub" => "123",
        "email" => "test@example.com",
        "role" => "admin",
        "iat" => System.os_time(:second) - 10000,
        "exp" => System.os_time(:second) - 100  # Expired 100 seconds ago
      }

      # Manually create expired token
      header = %{"alg" => "HS256", "typ" => "JWT"}
      header_encoded = header |> Jason.encode!() |> Base.url_encode64(padding: false)
      payload_encoded = claims |> Jason.encode!() |> Base.url_encode64(padding: false)
      signature_input = "#{header_encoded}.#{payload_encoded}"
      signature = :crypto.mac(:hmac, :sha256, Auth.secret_key(), signature_input)
                  |> Base.url_encode64(padding: false)
      expired_token = "#{signature_input}.#{signature}"

      assert {:error, :token_expired} = Auth.verify_token(expired_token)
    end

    test "rejects malformed token" do
      assert {:error, :invalid_token} = Auth.verify_token("notavalidtoken")
      assert {:error, :invalid_token} = Auth.verify_token("only.two")
    end
  end
end
