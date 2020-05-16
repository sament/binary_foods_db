defmodule BinaryFoodsDb.Kitchen.CompositionAgent do
  #defstruct [:id, :name, :inserted_at, :insterted_by]
  defstruct [compositions: [], last_composition_id: 0, cache: nil]


  alias BinaryFoodsDb.Kitchen.Composition

  #@app_dir File.cwd!()
   # @project_root_dir Path.join([@app_dir, "..", ".."])
   #@cache_file_path Path.join([@app_dir, "resources", "compositions.json"])


   def start_link do
     # cache will be nil if we are testing
      {:ok, cache} = open_cache(get_path())
      {compositions, last_composition_id} = load_from_cache(cache, {[], 0})
      Agent.start_link(fn -> %__MODULE__{cache: cache, compositions: compositions, last_composition_id: last_composition_id} end, name: __MODULE__)
   end

   def get_path() do
    if System.get_env("HEROKU_EXEC_URL") do
      "/app/resources/compositions.json"
    else
      Path.join([File.cwd!(), "resources", "compositions.json"])
    end
end
   def open_cache2() do
     # File.open(@app_dir <> "/resources/compositions.json", [:append, :read])
     File.open(get_path(), [:append, :read])
   end

   defp open_cache(:test), do: {:ok, nil}
   defp open_cache(_) do
     File.open(get_path(), [:append, :read])
   end

   defp load_from_cache(nil, _state), do: {[], 0}
   defp load_from_cache(cache, {compositions, _last_composition_id} = acc) do
     case IO.read(cache, :line) do
       :eof -> acc
       composition ->
         composition_struct =
           composition
             |> String.trim_trailing("\n")
             |> Poison.decode!(as: %Composition{})
         load_from_cache(cache, {[composition_struct | compositions], composition_struct.id})

     end
   end

   defp dump_to_cache(nil), do: nil
   defp dump_to_cache(cache) do
     File.close(cache)
     File.rm(get_path())
     {:ok, new_cache} = File.open(get_path(), [:append, :read])
     all()
       |> Enum.map(
           fn(composition) -> IO.write(new_cache, to_json(composition) <> "\n")
           end)
     Agent.update(__MODULE__, fn(struct) -> %{struct | cache: new_cache} end)
   end

   @doc """
   Return all of the compositions in the Agent's state as a list. This function
   is meant to act like a database select all.
   """
   def all() do
     Agent.get(__MODULE__, fn(struct) -> struct.compositions end)
   end



   def get(id) when is_integer(id) do
     all()
     |> Enum.find(fn(composition) -> composition.id == id end)
   end


   def reload() do
    cache = Agent.get(__MODULE__, fn(struct) -> struct.cache end)
    File.close(cache)
    {:ok, new_cache} = open_cache(get_path())
    {new_compositions, last_composition_id} = load_from_cache(new_cache, {[], 0})
    Agent.update(__MODULE__, fn(struct) -> %{struct | compositions: new_compositions} end)
    Agent.update(__MODULE__, fn(struct) -> %{struct | cache: new_cache} end)

   end

   @doc """
   Add a composition to the current state and append it to the cache file. This
   function is meant to behave like a database insert.
   """
   def add(%Composition{} = composition) do
     id = next_id()
     new_composition = %{composition | id: id}
     Agent.update(__MODULE__,
       fn(struct) ->
         %{struct | compositions: [new_composition | struct.compositions]}
       end)
     cache = Agent.get(__MODULE__, fn(s) -> s.cache end)
     write_to_cache(cache, new_composition)
     new_composition
   end

   defp write_to_cache(nil, _new_composition), do: nil
   defp write_to_cache(cache, new_composition) do
     IO.write(cache, to_json(new_composition) <> "\n")
   end

   defp to_json(composition) do
     # Remove Ecto field before encoding
    #***** composition |> Map.delete(:__meta__) |> Poison.encode! #ACTIVATE IF I USE ECTO @ %Composition{}
     composition |> Poison.encode!
   end

   @doc """
   Update an existing Cargo. Matching is done using the Cargo id value.
   """
   def update(%Composition{} = updated_composition) do
     new_composition_list =
       all()
       |> Enum.map(
           fn(composition) ->
             if composition.id == updated_composition.id do
               updated_composition
             else
               composition
             end
           end)
     Agent.update(__MODULE__,
         fn(struct) ->
           %{struct | compositions: new_composition_list}
         end)
     cache = Agent.get(__MODULE__, fn(struct) -> struct.cache end)
     dump_to_cache(cache)
     updated_composition
   end

   defp next_id() do
     Agent.get_and_update(__MODULE__,
     fn(struct) ->
       next_id = struct.last_composition_id + 1
       {next_id, %{struct | last_composition_id: next_id}}
     end)

 end


 end
