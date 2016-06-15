defmodule GnServer.Router.IntAPI do

  use Maru.Router
  
  IO.puts "Setup routing"

  alias GnServer.Data.Store, as: Store

  namespace :int do
    get "/" do
      json(conn, %{"I am": :genenetwork, api: :internal})
    end
  
    get "menu/main.json" do
      json(conn, Store.menu_main)
    end
  end
end
