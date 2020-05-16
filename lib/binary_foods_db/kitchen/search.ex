defmodule BinaryFoodsDb.Kitchen.Search do
  alias BinaryFoodsDb.Kitchen.MealAgent
  alias BinaryFoodsDb.Kitchen.IngredientAgent
  alias BinaryFoodsDb.Kitchen.CompositionAgent

 # alias BinaryFoodsDb.Kitchen.Meal
  alias BinaryFoodsDb.Kitchen.Ingredient
 # alias BinaryFoodsDb.Kitchen.Composition

 alias BinaryFoodsDb.Util.Sort



  def get_compositions_by_ingredient(ingredient_id) do
    CompositionAgent.all()
    |> Enum.filter(fn(composition) -> composition.ingredient_id == ingredient_id end )
  end

  def get_compositions(Ingredient, id) when is_integer(id) do
    get_compositions_by_ingredient(id)
  end


  def get_ingredient(id), do: Enum.find(IngredientAgent.all(), fn(i) -> i.id == id end)
  def get_ingredients(ids) when is_list(ids) when length ids > 0 do
    Enum.map(ids, fn(ing) ->
      Enum.find(IngredientAgent.all(), fn(ig) -> ig.id == ing end)
    end)
    |> Enum.filter( fn(d) -> d != nil end) #Removes nil/null value from list
  end


  # Get MEALS that contain [the specified] INGREDIENT
  # (BinaryFoods.Search)
  def get_meals_by_ingredient(id) do
    compositions = get_compositions_by_ingredient(id)
    meals =
    Enum.map(compositions, fn(composition) ->
      Enum.find(
        MealAgent.all(), fn(meal) ->
          meal.id == composition.meal_id
       end)
    end)
    len = length(meals)

    if len > 0 do
      %{ingredient: get_ingredient(id), meals: meals}
    else
      nil
    end
  end


  # Get MEALS that contains [multiple]INGREDIENTS
  # Compose MEALS that have n INGREDIENTS PRESENT

  def get_meals_by_ingredients(ingredient_ids) when is_list(ingredient_ids) do

   meals =
   Enum.map(ingredient_ids, fn(id) -> get_compositions(Ingredient, id) end)
    |> List.flatten
    |> Enum.map(fn(composition) -> Enum.find(MealAgent.all(), fn(meal) -> meal.id == composition.meal_id end)
      end)
    |> Enum.uniq ##Sort.remove_duplicate()
    len = length meals

    if len > 0 do
        %{ingredients: get_ingredients(ingredient_ids), meals: meals}
    else
        nil
    end

  end

  #Given [1,2,1,3,2] remove repetitions [1,2] so that the new list becomes [1,2,3]



# rc = Enum.map(ids, fn(id) -> BinaryFoodsDb.Kitchen.Search.get_compositions(BinaryFoodsDb.Kitchen.Ingredient, id) end)

def quicksort([]), do: []
def quicksort([h|t]) do
    lower = Enum.filter(t, &(&1 <= h))#is t element less than or equal to head?
    upper = Enum.filter(t, &(&1 > h))# is tail elemtn greater than head?
    quicksort(lower) ++ [h] ++ quicksort(upper)#recursive combine all list, this time around putting lower first
end


#alias BinaryFoodsDb.Kitchen.Search

#comps_meal_id = Enum.map(comps, fn c -> c.meal_id end) returns meal_ids all
# res2 = Enum.map(res, fn x -> Enum.find(res, fn r -> r.id != x.id end) end) returns repitions


# iex(79)> b1=Enum.map(a1, fn a -> a.id end)
# [3, 2, 1]
# iex(80)> b2 = Enum.map(a2, fn b -> b.id end)
# [1, 3]
# iex(81)> b1--b2
# [2]
# iex(82)> b2++b1--b2
# [1, 3, 2]
# iex(83)>
# iex(83)> c = b1++b2
# [3, 2, 1, 1, 3]
# iex(85)> c--b2 #b2 is second list that contains found repitions. Question How do i create list of repitiions
# [2, 1, 3]
# comps_meal_id = [1, 2, 1, 3, 2]
# iex(105)> Enum.reduce_while(c1, c1, fn(c, acc) -> if c == c1, do: {:cont, acc}, else: {:halt, acc} end)
# [1, 2, 1, 3, 2]


# Reduce as a building block
# Reduce (sometimes called fold) is a basic building block in functional programming.
#  Almost all of the functions in the Enum module can be implemented on top of reduce.
#  Those functions often rely on other operations, such as Enum.reverse/1, which are optimized by the runtime.

# For example, we could implement map/2 in terms of reduce/3 as follows:

# def my_map(enumerable, fun) do
#   enumerable
#   |> Enum.reduce([], fn x, acc -> [fun.(x) | acc] end)
#   |> Enum.reverse()
# end
# In the example above, Enum.reduce/3 accumulates the result of each call to fun into a list in reverse order,
#  which is correctly ordered at the end by calling Enum.reverse/1.

# Implementing functions like map/2, filter/2 and others are a good exercise for understanding the power behind Enum.reduce/3.
#  When an operation cannot be expressed by any of the functions in the Enum module, developers will most likely resort to reduce/3.



# scan(enumerable, fun) View Source
# scan(t(), (element(), any() -> any())) :: list()
# Applies the given function to each element in the enumerable, storing the result in a list and passing it as the accumulator for the next computation.
#  Uses the first element in the enumerable as the starting value.

#  Examples
# Enum.scan(1..5, &(&1 + &2))
# [1, 3, 6, 10, 15]
# Link to this function
# scan(enumerable, acc, fun) View Source
# scan(t(), any(), (element(), any() -> any())) :: list()
# Applies the given function to each element in the enumerable, storing the result in a list and passing it as the accumulator for the next computation.
#  Uses the given acc as the starting value.

#  Examples
# Enum.scan(1..5, 0, &(&1 + &2))
# [1, 3, 6, 10, 15]



end
