defmodule BinaryFoodsDb.Kitchen.Composition do
  defstruct [
    :id,
    :meal_id,
    :ingredient_id,
    :inserted_at,
    :inserted_by,
    :ordinal]
end
