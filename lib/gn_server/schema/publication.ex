defmodule GnServer.Schema.Publication do
  use Ecto.Schema

  schema "Publication" do
    field :PubMed_ID, :integer
    field :title, :string
    field :year, :integer
  end

end
