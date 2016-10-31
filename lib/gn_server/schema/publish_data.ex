defmodule GnServer.Schema.PublishData do
  use Ecto.Schema

  schema "PublishData" do
    # field :id, :integer
    field :strainid, :integer
    field :value, :float
  end

end
