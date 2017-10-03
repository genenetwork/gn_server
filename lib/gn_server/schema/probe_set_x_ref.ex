defmodule GnServer.Schema.ProbeSetXRef do
  use Ecto.Schema

  schema "ProbeSetXRef" do
    field :ProbeSetFreezeId, :integer, primary_key: true
    field :ProbeSetId, :integer
    field :DataId, :integer
    field :Locus_old
    field :LRS_old, :float
    field :pValue_old, :float
    field :mean, :float
    field :se, :float
    field :Locus
    field :LRS, :float
    field :pValue, :float
    field :additive, :float
    field :h2, :float
  end

end
