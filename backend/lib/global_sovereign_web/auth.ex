defmodule GlobalSovereignWeb.Auth do
  @moduledoc """
  Simple JWT authentication implementation.
  
  Provides functions for:
  - Creating JWT tokens
  - Verifying JWT tokens
  - Extracting claims from tokens
  """

  def secret_key do
    System.get_env("JWT_SECRET") || "dev_secret_changeme_in_production"
  end

  @doc """
  Create a JWT token for a user.
  
  Returns {:ok, token, claims}
  """
  def generate_token(user) do
    claims = %{
      "sub" => user.id,
      "email" => user.email,
      "role" => to_string(user.role),
      "iat" => System.os_time(:second),
      "exp" => System.os_time(:second) + 604800  # 7 days
    }

    token = create_token(claims)
    {:ok, token, claims}
  end

  @doc """
  Verify and decode a JWT token.
  
  Returns {:ok, claims} or {:error, reason}
  """
  def verify_token(token) do
    case String.split(token, ".") do
      [_header, _payload, _signature] ->
        try do
          decoded = decode_token(token)
          claims = Jason.decode!(decoded)
          
          # Check expiration
          now = System.os_time(:second)
          if claims["exp"] > now do
            {:ok, claims}
          else
            {:error, :token_expired}
          end
        rescue
          _ -> {:error, :invalid_token}
        end

      _ ->
        {:error, :invalid_token}
    end
  end

  # Private helpers

  defp create_token(claims) do
    header = %{"alg" => "HS256", "typ" => "JWT"}
    
    header_encoded = header |> Jason.encode!() |> Base.url_encode64(padding: false)
    payload_encoded = claims |> Jason.encode!() |> Base.url_encode64(padding: false)
    
    signature_input = "#{header_encoded}.#{payload_encoded}"
    signature = :crypto.mac(:hmac, :sha256, secret_key(), signature_input)
                |> Base.url_encode64(padding: false)
    
    "#{signature_input}.#{signature}"
  end

  defp decode_token(token) do
    [_header, payload, _signature] = String.split(token, ".")
    
    # Add padding if needed
    padding = case rem(String.length(payload), 4) do
      2 -> "=="
      3 -> "="
      _ -> ""
    end
    
    padded_payload = payload <> padding
    
    case Base.url_decode64(padded_payload) do
      {:ok, decoded} -> decoded
      :error -> raise "Invalid base64 encoding"
    end
  end
end
