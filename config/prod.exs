use Mix.Config

config :binary_foods_db, BinaryFoodsDb.Endpoint,
  port: String.to_integer(System.get_env("PORT") || "4444")

config :binary_foods_db, redirect_url: System.get_env("REDIRECT_URL")
