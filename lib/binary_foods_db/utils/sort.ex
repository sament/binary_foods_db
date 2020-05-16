defmodule BinaryFoodsDb.Util.Sort do
   @doc """
  Removes duplicate elements from a list of  arbitrary type/object.
  This function removes duplicate entries for Ingredients, Meals etc.
  """


def remove_duplicate([]), do: []
def remove_duplicate([h|t]) do #This works!
    not_found = Enum.filter(t, &(&1 != h))# get all element in tail that isn't in the head
    remove_duplicate(not_found) ++ [h] #recursive call to
   # [remove_duplicate(not_found) | h] faster
end
end

