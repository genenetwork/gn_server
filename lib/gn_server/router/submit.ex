# Contains the data submission routes

defmodule GnServer.Router.Submit do

  use Maru.Router
  # plug CORSPlug, origin: ["*"]

  IO.puts "Setup submit routing"

  alias GnServer.Data.Store, as: Store
  # alias GnServer.Logic.Assemble, as: Assemble

  namespace :submit do
    namespace :phenotypes do
      params do
        requires :tokenid, type: String
        requires :dataset, type: String
      end
      put do
        result = Store.update(params)
        json(conn, result)
      end
    end

    get "menu/main.json" do
      json(conn, Assemble.menu_main)
      #json(conn, Assemble.menu_main)
    end
  end
end
