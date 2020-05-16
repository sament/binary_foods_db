defmodule BinaryFoodsDb.Kitchen.Meal do
  defstruct [
    :id,
    :name,
    :inserted_at,
    :inserted_by,
    :ingredients]
#best that? :ingredients are #PIDS (and not actual struct) to actual ingredient so there is only one-source-of-truth
#This is also so that the ingredient can be updated from one point and always reflected when called

   @moduledoc """
  The root* of the Entities AGGREGATE*.

  From the DDD book: [An AGGREGATE is] a cluster of associated objects that
  are treated as a unit for the purgpose of data changes. External references are
  restricted to one member of the AGGREGATE, designated as the root.
  """
  # use Ecto.Schema
  # import Ecto.Changeset
   alias BinaryFoodsDb.Kitchen.Meal

  # @derive {Phoenix.Param, key: :tracking_id}
  # schema "entities" do
  #   field :id, :integer
  #   timestamps()
  # end

  # @doc false
  # def changeset(%Entity{} = entity, attrs) do
  #   entity
  #   |> cast(attrs, [:id])
  #   |> validate_required([:id])
  # end


  def start_link() do
    Agent.start_link(fn -> %Meal{} end)
  end


  # Would return error of process not started or
  # ** (EXIT) no process: the process is not alive or there's no process currently associated with the given name,
  #     possibly because its application isn't started  #
  #def get_name() do
  #   Agent.get(__MODULE__, fn m -> m.name end)
  # end
  def get_name(meal) do
    Agent.get(meal, fn m -> m.name end)
  end

end
