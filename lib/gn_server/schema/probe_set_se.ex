defmodule GnServer.Schema.ProbeSetSE do
  use Ecto.Schema

  schema "probesetse" do
    field :DataId, :integer, primary_key: true
    field :StrainId, :integer, primary_key: true
    field :error, :float
  end
  
end