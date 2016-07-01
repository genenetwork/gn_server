defmodule GnServer.Schema.Strain do
  use Ecto.Schema

  schema "strain" do
    field :Name
    field :Name2
    field :SpeciesId, :integer
    field :Symbol
    field :Alias
  end
  
end