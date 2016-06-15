defmodule GnServer.Router.IntAPI do

  use Maru.Router
  
  IO.puts "Setup routing"

  alias GnServer.Data.Store, as: Store
  alias GnServer.Logic.Assemble, as: Assemble

  namespace :int do
    get "/" do
      json(conn, %{"I am": :genenetwork, api: :internal})
    end
  
    get "menu/main.json" do
      json(conn, Assemble.menu_main)
    end
  end
end
