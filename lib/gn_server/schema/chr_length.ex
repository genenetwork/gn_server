defmodule GnServer.Schema.Chr_Length do
  use Ecto.Schema

  schema "chr_length" do
    field :Name
    field :SpeciesId, :integer, primary_key: true
    field :OrderId, :integer
    field :Length, :integer
    field :Length_mm8, :integer
  end
  
end