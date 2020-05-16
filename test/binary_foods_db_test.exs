defmodule BinaryFoodsDbTest do
  use ExUnit.Case
  alias BinaServiceWeb.{MealRouter, }

  describe "basic" do
   test "the truth" do
      assert 1 + 1 == 2
      assert 3 + 2 == 5
      1
    end

    test "the lie" do
      refute 1 + 1 == 3
    end
  end



end
