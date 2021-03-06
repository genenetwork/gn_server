defmodule GnServer.Schema.PublishFreeze do
  use Ecto.Schema

  schema "PublishFreeze" do
    field :Name
    field :FullName
    field :ShortName
    field :public, :integer
    field :InbredSetId, :integer
    field :confidentiality, :integer
    field :AuthorisedUsers
  end
  
end
