defmodule GlobalSovereign.Repo do
  use Ecto.Repo,
    otp_app: :global_sovereign,
    adapter: Ecto.Adapters.Postgres
end
