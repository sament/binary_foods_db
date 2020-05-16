defmodule BinaryFoodsDb.Endpoint do
  use Plug.Router
  use Plug.Debugger
  use Plug.ErrorHandler

  #alias BinaryFoodsDb.Router
  alias BinaryFoodsDb.MealRouter
  alias BinaryFoodsDb.IngredientRouter

  alias Plug.{Adapters.Cowboy2, HTML}

  require Logger

  plug(Plug.Logger, log: :debug)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/bot", to: BinaryFoodsDb.Router)
  forward("/meals", to: MealRouter)
  forward("/ingredients", to: IngredientRouter)
  forward("/search", to: BinaryFoodsDb.SearchRouter)


  match _ do
    conn
    |> put_resp_header("location", redirect_url())
    |> put_resp_content_type("text/html")
    |> send_resp(302, redirect_body())
  end

  defp redirect_body do
    ~S(<html><body>You are being <a href=")
    |> Kernel.<>(HTML.html_escape(redirect_url()))
    |> Kernel.<>(~S(">redirected</a>.</body></html>))
  end

  defp config, do: Application.fetch_env(:binary_foods_db, __MODULE__)
  defp redirect_url, do: Application.get_env(:binary_foods_db, :redirect_url)

  def handle_errors(%{status: status} = conn, %{kind: _kind, reason: _reason, stack: _stack}),
    do: send_resp(conn, status, "Something went wrong")


    def child_spec(opts) do
      %{
        id: __MODULE__,
        start: {__MODULE__, :start_link, [opts]}
      }
    end

    def start_link(_opts) do
      with {:ok, [port: port] = config} <- config() do
        Logger.info("Starting server at http://localhost:#{port}/")
        Cowboy2.http(__MODULE__, [], config)
      end
    end

  end
