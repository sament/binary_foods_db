defmodule BinaryFoodsDb.Repo do


  alias BinaryFoodsDb.Kitchen.Meal
  alias BinaryFoodsDb.Kitchen.MealAgent
  alias BinaryFoodsDb.Kitchen.Ingredient
  alias BinaryFoodsDb.Kitchen.IngredientAgent

  @doc """
  Retrieve all of the Meals from the Meal Agent.
  """
  def all(Meal) do
    MealAgent.all()
  end


   @doc """
  Retrieve all of the Ingredients from the Ingredient Agent.
  """
  def all(Ingredient) do
    IngredientAgent.all()
  end


  def get(Meal, id) do
    MealAgent.get(String.to_integer(id))
  end

  def get(Ingredient, id) do
    IngredientAgent.get(String.to_integer(id))
  end



  def search_meals_by_ingredient(id) when is_integer(id) do
    BinaryFoodsDb.Kitchen.Search.get_meals_by_ingredient(id)
  end

  def  search_meals_by_ingredients(ids) when is_list(ids) do
    BinaryFoodsDb.Kitchen.Search.get_meals_by_ingredients(ids)
  end
end
