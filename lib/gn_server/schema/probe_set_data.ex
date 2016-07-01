defmodule GnServer.Schema.ProbeSetData do
  use Ecto.Schema

  schema "probesetdata" do
    field :StrainId, :integer
    field :value, :float
  end
  
end