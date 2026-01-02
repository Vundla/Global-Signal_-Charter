defmodule GlobalSovereignWeb.Plugs.RateLimiter do
  @moduledoc """
  PlugAttack-based rate limiter for protecting against abuse.
  
  Rate limits: 60 requests per minute per IP address
  
  Attach to router with:
    pipe_through(:api)
    plug GlobalSovereignWeb.Plugs.RateLimiter
  """
  use PlugAttack

  def allow_action(conn, _opts) do
    ip = get_ip(conn)
    key = "rate_limit:#{ip}"
    
    case PlugAttack.Storage.Ets.increment(key, 1, 60, 1) do
      {:ok, count} when count <= 60 -> {:allow, conn}
      {:ok, _count} -> {:deny, throttle_response(conn)}
      _ -> {:allow, conn}
    end
  end

  defp get_ip(conn) do
    conn.remote_ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  defp throttle_response(conn) do
    # sobelow_skip ["XSS.SendResp"]
    # Safe: sending JSON-encoded response with proper content-type header
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.send_resp(429, Jason.encode!(%{error: "Rate limit exceeded"}))
    |> Plug.Conn.halt()
  end
end
