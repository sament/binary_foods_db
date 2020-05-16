defmodule BinaryFoodsDb.IngredientRouter do
  use Plug.Router
 # Parameters can be accesed at conn.params and conn.path.params

  alias BinaryFoodsDb.Repo
  alias BinaryFoodsDb.Kitchen.Ingredient

  plug(:match)
  plug(:dispatch)

  @content_type "application/json"


  get "/" do

    result = Repo.all(Ingredient)
    case result do
    nil ->
      notFound(conn)
     _ ->
       conn
    |> put_resp_content_type(@content_type)
    |> send_resp(200,  Poison.encode!(result))
    end


  end


  get "/:id" do
    result = Repo.get(Ingredient, id)
    case result do
      nil ->
        notFound(conn)
        _ ->
         conn
        |> put_resp_content_type(@content_type)
        |> send_resp(200,  Poison.encode!(result))
    end

  end
  get "v2/:id" do
    result = Repo.get(Ingredient, id)
         conn
        |> put_resp_content_type(@content_type)
        |> send_resp(200,  Poison.encode!(result))

  end

  defp  notFound(conn) do
    conn
    |>put_resp_content_type(@content_type)
    |> send_resp(404,  Poison.encode!("Not found!"))
  end
end
