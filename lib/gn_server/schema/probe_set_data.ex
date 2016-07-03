defmodule GnServer.Schema.ProbeSetData do
  use Ecto.Schema

  schema "ProbeSetData" do
    field :StrainId, :integer
    field :value, :float
  end

end
