defmodule BinaryFoodsDb.Application do
  use Application


  def start(_type, _args), do: Supervisor.start_link(children(), opts())

  defp children do
    import Supervisor.Spec, warn: false
    [
      supervisor(BinaryFoodsDb.Kitchen.MealAgent, []),
      supervisor(BinaryFoodsDb.Kitchen.IngredientAgent, []),
      supervisor(BinaryFoodsDb.Kitchen.CompositionAgent, []),
      BinaryFoodsDb.Endpoint,
    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: BinaryFoodsDb.Supervisor
    ]
  end
end
