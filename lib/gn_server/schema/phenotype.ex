defmodule GnServer.Schema.Phenotype do
  use Ecto.Schema

  schema "Phenotype" do
    field :post_publication_description, :string
  end

end
