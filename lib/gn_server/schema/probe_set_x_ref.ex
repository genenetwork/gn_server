defmodule GnServer.Schema.ProbeSetXRef do
  use Ecto.Schema

  schema "probesetxref" do
    field :ProbeSetFreezeId, :integer, primary_key: true
    field :ProbeSetId, :integer
    field :DataId, :integer
    field :Locus_old
    field :LRS_old, :integer
    field :pValue_old, :integer
    field :mean, :integer
    field :se, :integer
    field :Locus
    field :LRS, :integer
    field :pValue, :integer
    field :additive, :integer
    field :h2, :float
  end
  
end