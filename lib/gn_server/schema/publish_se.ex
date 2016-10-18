defmodule GnServer.Schema.PublishSE do
  use Ecto.Schema

  schema "PublishSE" do
    # field :id, :integer
    field :strainid, :integer
    field :error, :float
  end

end
