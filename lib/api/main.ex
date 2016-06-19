defmodule GnServer.Router.MainAPI do

  use Maru.Router

  IO.puts "Setup routing"

  alias GnServer.Data.Store, as: Store

  @doc """
  Fetch all species in the database 
  """
  
  get "/species" do
    # CSV version: text(conn,Enum.join(nlist,"\n"))
    json(conn, Store.species)
  end

  @doc """ 
  Get the properties of a cross 
  """
  
  get "/cross/BXD" do
    json(conn, Assemble.cross("BXD"))
  end
  
  get "/datasets" do
    json(conn, Store.datasets)
  end

  get do
    json(conn, %{"I am": :genenetwork})
  end

  get "/hey" do
    json(conn, %{"I am": :genenetwork})
  end

end

