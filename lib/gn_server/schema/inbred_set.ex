defmodule GnServer.Schema.InbredSet do
  use Ecto.Schema

  schema "inbredset" do
    field :InbredSetId, :integer
    field :InbredSetName
    field :Name
    field :SpeciesId, :integer
    field :FullName
    field :public, :integer
    field :MappingMethodId
    field :GeneticType
    field :orderid, :integer
  end
  
end