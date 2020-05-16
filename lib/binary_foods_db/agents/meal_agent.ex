defmodule BinaryFoodsDb.Kitchen.MealAgent do
 #defstruct [:id, :name, :inserted_at, :insterted_by]
 defstruct [meals: [], last_meal_id: 0, cache: nil]


 alias BinaryFoodsDb.Kitchen.Meal

 #@app_dir File.cwd!()
  # @project_root_dir Path.join([@app_dir, "..", ".."])
  #@cache_file_path Path.join([@app_dir, "resources", "meals.json"])


  def get_path() do

      if System.get_env("HEROKU_EXEC_URL") do
        "/app/resources/meals.json"
      else
        Path.join([File.cwd!(), "resources", "meals.json"])
      end
  end


  def start_link do
    # cache will be nil if we are testing
     {:ok, cache} = open_cache(get_path())
     {meals, last_meal_id} = load_from_cache(cache, {[], 0})
     Agent.start_link(fn -> %__MODULE__{cache: cache, meals: meals, last_meal_id: last_meal_id} end, name: __MODULE__)
     #__MODULE__ returns : Elixir.BinaryFoodsDb.Kitchen.MealAgent
  end


  def open_cache2() do
    # File.open(@app_dir <> "/resources/meals.json", [:append, :read])
    File.open(get_path(), [:append, :read])
  end

  defp open_cache(:test), do: {:ok, nil}
  defp open_cache(_) do
    File.open(get_path(), [:append, :read])
  end

  defp load_from_cache(nil, _state), do: {[], 0}
  defp load_from_cache(cache, {meals, _last_meal_id} = acc) do
    case IO.read(cache, :line) do #** (CaseClauseError) no case clause matching: {"{\"name\":\"Asaro Yam Porridge\",\"inserted_by\":\"@samiso\",\"inserted_at\":1560496918,\"id\":1}\n"}
      :eof -> acc
      meal ->
        meal_struct =
          meal
            |> String.trim_trailing("\n")
            |> Poison.decode!(as: %Meal{})
        load_from_cache(cache, {[meal_struct | meals], meal_struct.id})

    end
  end

  defp dump_to_cache(nil), do: nil
  defp dump_to_cache(cache) do
    File.close(cache)
    File.rm(get_path())
    {:ok, new_cache} = File.open(get_path(), [:append, :read])
    all()
      |> Enum.map(
          fn(meal) -> IO.write(new_cache, to_json(meal) <> "\n")
          end)
    Agent.update(__MODULE__, fn(struct) -> %{struct | cache: new_cache} end)
  end

  @doc """
  Return all of the meals in the Agent's state as a list. This function
  is meant to act like a database select all.
  """
  def all() do
    Agent.get(__MODULE__, fn(struct) -> struct.meals end)
  end



  def get(id) when is_integer(id) do
    all()
    |> Enum.find(fn(meal) -> meal.id == id end)
  end


  @doc """
  Add a meal to the current state and append it to the cache file. This
  function is meant to behave like a database insert.
  """
  def add(%Meal{} = meal) do
    id = next_id()
    new_meal = %{meal | id: id}
    Agent.update(__MODULE__,
      fn(struct) ->
        %{struct | meals: [new_meal | struct.meals]}
      end)
    cache = Agent.get(__MODULE__, fn(s) -> s.cache end)
    write_to_cache(cache, new_meal)
    new_meal
  end

  defp write_to_cache(nil, _new_meal), do: nil
  defp write_to_cache(cache, new_meal) do
    IO.write(cache, to_json(new_meal) <> "\n")
  end

  defp to_json(meal) do
    # Remove Ecto field before encoding
   #***** meal |> Map.delete(:__meta__) |> Poison.encode! #ACTIVATE IF I USE ECTO @ %Meal{}
    meal |> Poison.encode!
  end

  @doc """
  Update an existing Cargo. Matching is done using the Cargo id value.
  """
  def update(%Meal{} = updated_meal) do
    new_meal_list =
      all()
      |> Enum.map(
          fn(meal) ->
            if meal.id == updated_meal.id do
              updated_meal
            else
              meal
            end
          end)
    Agent.update(__MODULE__,
        fn(struct) ->
          %{struct | meals: new_meal_list}# same as:  Map.put(struct, :meals, new_meal_list)
        end)
    cache = Agent.get(__MODULE__, fn(struct) -> struct.cache end)
    dump_to_cache(cache)
    updated_meal
  end

  defp next_id() do
    Agent.get_and_update(__MODULE__,
    fn(struct) ->
      next_id = struct.last_meal_id + 1
      {next_id, %{struct | last_meal_id: next_id}}
    end)

end


end
