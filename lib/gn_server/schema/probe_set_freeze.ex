defmodule GnServer.Schema.ProbeSetFreeze do
  use Ecto.Schema

  schema "probesetfreeze" do
    field :ProbeFreezeId, :integer
    field :AvgID, :integer
    field :Name
    field :Name2
    field :FullName
    field :ShortName
    field :OrderList, :float
    field :public, :integer
    field :confidentiality, :integer
    field :AuthorisedUsers
    field :DataScale
  end
  
end