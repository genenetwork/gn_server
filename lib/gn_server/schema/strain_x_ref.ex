defmodule GnServer.Schema.StrainXRef do
  use Ecto.Schema

  schema "StrainXRef" do
    field :InbredSetId, :integer, primary_key: true
    field :StrainId, :integer, primary_key: true
    field :OrderId, :integer
    field :Used_for_mapping
    field :PedigreeStatus
  end
  
end
