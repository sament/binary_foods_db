defmodule BinaryFoodsDb.Util do

  def to_stringX(%{} = m) do
    m
    |> Map.to_list()
    |> to_string()
  end
  def to_stringX(l) when is_list(l) do
    values =
    l
    |> Enum.map(&to_stringX/1)
    |> Enum.join(",")

    "[#{values}]"
  end
  def to_stringX(elem), do: "#{elem}"
end

defmodule BinaryFoodsDb.BinaryFoods do
  def new_behaviour(expectations) do
  #  %{expectations}
  expectations
  end
end

defmodule BinaryFoodsDb.SearchRouter do
  use Plug.Router

  alias BinaryFoodsDb.Repo
  alias BinaryFoodsDb.Kitchen.Search
  alias BinaryFoodsDb.BinaryFoods
  alias BinaryFoodsDb.Util

  plug(:match)
  plug Plug.Parsers, parsers: [:json],
  pass:  ["application/json"],
  json_decoder: Jason

  plug(:dispatch)

  @content_type "application/json"

  get "/purpose" do
    inspire = ["modelling solution", "economic_activities", "production_boost", "save_cost", "effeciency"]
    purpose = [
      %{
        id: :genesis,
        brief: "AMAZ_NG EXPERIENCE __ SM_RT W_RK_RS",
      },
      %{
        id: :method,
        brief: "",
        path: inspire |> BinaryFoods.new_behaviour
      }]
    send_resp(conn, 200, purpose |> Util.to_stringX)
  end

  post "/" do
    params = conn.body_params
    ingredients = params["ingredients"]
    len = length(ingredients)
    if len > 1 do
      result = Repo.search_meals_by_ingredients(ingredients)
      display_result(conn, result)
    end

    if len == 1 do
     result = Repo.search_meals_by_ingredient(List.first(ingredients))
     display_result(conn, result)
    end
end

def display_result(conn, result) do
  case result do
    nil -> notFound(conn)
    [] ->  notFound(conn)
    _ ->
      conn
      |> put_resp_content_type(@content_type)
      |> send_resp(200,  Poison.encode!(result))
  end
end



  defp  notFound(conn) do
      conn
      |>put_resp_content_type(@content_type)
      |> send_resp(404,  Poison.encode!("Not found!"))
    end

    # IO.inspect conn.body_params # Prints JSON POST body

end
