defmodule BinaryFoodsDb.Kitchen.IngredientAgent do
  #defstruct [:id, :name, :inserted_at, :insterted_by]
  defstruct [ingredients: [], last_ingredient_id: 0, cache: nil]


  alias BinaryFoodsDb.Kitchen.Ingredient

  #@app_dir File.cwd!()
   # @project_root_dir Path.join([@app_dir, "..", ".."])
   #@cache_file_path Path.join([@app_dir, "resources", "ingredients.json"])


   def start_link do
     # cache will be nil if we are testing
      {:ok, cache} = open_cache(get_path())
      {ingredients, last_ingredient_id} = load_from_cache(cache, {[], 0})
      Agent.start_link(fn -> %__MODULE__{cache: cache, ingredients: ingredients, last_ingredient_id: last_ingredient_id} end, name: __MODULE__)
   end

   def get_path() do
      if System.get_env("HEROKU_EXEC_URL") do
        "/app/resources/ingredients.json"
      else
        Path.join([File.cwd!(), "resources", "ingredients.json"])
      end
  end

   def open_cache2() do
     # File.open(@app_dir <> "/resources/ingredients.json", [:append, :read])
     File.open(get_path(), [:append, :read])
   end

   defp open_cache(:test), do: {:ok, nil}
   defp open_cache(_) do
     File.open(get_path(), [:append, :read])
   end

   defp load_from_cache(nil, _state), do: {[], 0}
   defp load_from_cache(cache, {ingredients, _last_ingredient_id} = acc) do
     case IO.read(cache, :line) do
       :eof -> acc
       ingredient ->
         ingredient_struct =
           ingredient
             |> String.trim_trailing("\n")
             |> Poison.decode!(as: %Ingredient{})
         load_from_cache(cache, {[ingredient_struct | ingredients], ingredient_struct.id})

     end
   end

   defp dump_to_cache(nil), do: nil
   defp dump_to_cache(cache) do
     File.close(cache)
     File.rm(get_path())
     {:ok, new_cache} = File.open(get_path(), [:append, :read])
     all()
       |> Enum.map(
           fn(Ingredient) -> IO.write(new_cache, to_json(Ingredient) <> "\n")
           end)
     Agent.update(__MODULE__, fn(struct) -> %{struct | cache: new_cache} end)
   end

   @doc """
   Return all of the ingredients in the Agent's state as a list. This function
   is meant to act like a database select all.
   """
   def all() do
     Agent.get(__MODULE__, fn(struct) -> struct.ingredients end)
   end



   def get(id) when is_integer(id) do
     all()
     |> Enum.find(fn(ingredient) -> ingredient.id == id end)
   end


   @doc """
   @BinaryFoods
   Add a Ingredient to the current state and append it to the cache file. This
   function is meant to behave like a database insert.
   BINARY FOODS
   """
   def add(%Ingredient{} = ingredient) do
     id = next_id()
     new_ingredient = %{ingredient | id: id}
     Agent.update(__MODULE__,
       fn(struct) ->
         %{struct | ingredients: [new_ingredient | struct.ingredients]}
       end)
     cache = Agent.get(__MODULE__, fn(s) -> s.cache end)
     write_to_cache(cache, new_ingredient)
     new_ingredient
   end

   defp write_to_cache(nil, _new_ingredient), do: nil
   defp write_to_cache(cache, new_ingredient) do
     IO.write(cache, to_json(new_ingredient) <> "\n")
   end

   defp to_json(ingredient) do
     # Remove Ecto field before encoding
    #***** ingredient |> Map.delete(:__meta__) |> Poison.encode! #ACTIVATE IF I USE ECTO @ %Ingredient{}
     ingredient |> Poison.encode!
   end

   @doc """
   Update an existing Ingredient. Matching is done using the id value.
   """
   def update(%Ingredient{} = updated_ingredient) do
     new_ingredient_list =
       all()
       |> Enum.map(
           fn(ingredient) ->
             if ingredient.id == updated_ingredient.id do
               updated_ingredient
             else
               ingredient
             end
           end)
     Agent.update(__MODULE__,
         fn(struct) ->
           %{struct | ingredients: new_ingredient_list}
         end)
     cache = Agent.get(__MODULE__, fn(struct) -> struct.cache end)
     dump_to_cache(cache)
     updated_ingredient
   end

   defp next_id() do
     Agent.get_and_update(__MODULE__,
     fn(struct) ->
       next_id = struct.last_ingredient_id + 1
       {next_id, %{struct | last_ingredient_id: next_id}}
     end)

 end


 end
