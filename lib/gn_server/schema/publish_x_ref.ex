defmodule GnServer.Schema.PublishXRef do
  use Ecto.Schema

  schema "PublishXRef" do
    # field :Id, :integer, primary_key: true
    field :InbredSetId, :integer
    field :PhenotypeId, :integer
    field :PublicationId, :integer
    field :DataId, :integer
    field :Locus, :string
    field :LRS, :integer
    field :additive, :float
  end

end
