defmodule GnServer.Schema.PublishData do
  use Ecto.Schema

  schema "PublishData" do
    field :strainid, :integer
    field :value, :float
  end

end
