defmodule GlobalSovereignWeb.Router do
  use GlobalSovereignWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug GlobalSovereignWeb.Plugs.RateLimiter
  end

  # Metrics endpoint for Prometheus scraping
  forward "/metrics", PromEx.Plug

  # Phase 4: GraphQL API (Public queries, authenticated mutations)
  scope "/api" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug,
      schema: GlobalSovereignWeb.Schema,
      context: &GlobalSovereignWeb.GraphQL.context/1

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: GlobalSovereignWeb.Schema,
        interface: :playground
    end
  end

  scope "/api", GlobalSovereignWeb do
    pipe_through :api

    get "/healthcheck", HealthController, :index
  end

  scope "/api/auth", GlobalSovereignWeb.API do
    pipe_through :api

    post "/login", AuthController, :login
    post "/register", AuthController, :register
  end

  scope "/api", GlobalSovereignWeb.API, as: :api do
    pipe_through :api

    # Phase 1: GDP Covenant
    get "/countries/stats", CountryController, :stats
    resources "/countries", CountryController, except: [:new, :edit]

    # Phase 2: Economic Orchestration
    get "/agriculture/stats", AgricultureController, :stats
    resources "/agriculture", AgricultureController, except: [:new, :edit]

    get "/minerals/stats", MineralController, :stats
    resources "/minerals", MineralController, except: [:new, :edit]

    get "/energy/stats", EnergyController, :stats
    resources "/energy", EnergyController, except: [:new, :edit]

    get "/tech/stats", TechController, :stats
    resources "/tech", TechController, except: [:new, :edit]

    # Phase 2 Extension: Health & Education
    get "/health/stats", HealthController, :stats
    resources "/health", HealthController, except: [:new, :edit]

    get "/education/stats", EducationController, :stats
    resources "/education", EducationController, except: [:new, :edit]
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:global_sovereign, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: GlobalSovereign.Telemetry
    end
  end
end
