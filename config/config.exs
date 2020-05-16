use Mix.Config

config :binary_foods_db, BinaryFoodsDb.Endpoint, port: 4000
config :binary_foods_db, redirect_url: "http://localhost:4000/bot"

import_config "#{Mix.env()}.exs"
