defmodule GnServer.Schema.Tissue do
  use Ecto.Schema

  schema "Tissue" do
    field :TissueId, :integer
    field :TissueName
    field :Name
    field :ShortName
    field :BIRN_lex_ID
    field :BIRN_lex_Name
  end
  
end
