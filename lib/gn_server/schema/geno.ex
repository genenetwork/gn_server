defmodule GnServer.Schema.Geno do
  use Ecto.Schema

  schema "Geno" do
    field :SpeciesId, :integer
    field :Name
    field :Maker_Name
    field :Chr
    field :Mb, :integer
    field :Sequence
    field :Source
    field :chr_num, :integer
    field :Source2
    field :Comments
    field :used_by_geno_file
    field :Mb_mm8, :integer
    field :Chr_mm8
  end
  
end
