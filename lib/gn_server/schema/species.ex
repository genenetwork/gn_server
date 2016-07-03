defmodule GnServer.Schema.Species do
  use Ecto.Schema

  schema "species" do
    field :SpeciesId, :integer
    field :SpeciesName
    field :Name
    field :MenuName
    field :FullName
    field :TaxonomyId, :integer
    field :OrderId, :integer
  end
  
end