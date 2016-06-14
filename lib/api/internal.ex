defmodule GnServer.Router.IntAPI do

  use Maru.Router
  
  IO.puts "Setup routing"

  alias GnServer.Data.Store, as: Store


  get "int/" do
    json(conn, %{"I am": :genenetwork, api: :internal})
  end
  
  get "int/menu/species" do
    json(conn, Store.menu_species)
  end

end
