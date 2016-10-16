defmodule GnServer.Schema.Publication do
  use Ecto.Schema

  schema "Publication" do
    field :pubmed_id, :integer
    field :title, :string
    field :year, :integer
  end

end
