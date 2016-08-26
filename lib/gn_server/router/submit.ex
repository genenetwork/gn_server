# Contains the data submission routes

defmodule GnServer.Router.Submit do

  use Maru.Router
  # plug CORSPlug, origin: ["*"]

  IO.puts "Setup submit routing"

  alias GnServer.Data.UpdateStore, as: UpdateStore
  # alias GnServer.Logic.Assemble, as: Assemble

  # Test with:
  #   echo -e -n "hello world" |curl -X PUT -d @- -d message=test -d message=message http://127.0.0.1:8880/echo
  namespace :echo do
    params do
      # requires :tokenid, type: String
      optional :message, type: String
    end
    put do
      # IO.inspect(conn)
      # IO.inspect(conn.params)
      # IO.inspect Map.keys(conn.params)
      body = Map.keys(conn.params) |> List.first
      # IO.inspect(body)
      result = UpdateStore.echo(params,body)
      json(conn, result)
    end
  end

  namespace :submit do
    namespace :phenotypes do
      params do
        # requires :tokenid, type: String
        optional :dataset, type: String
      end
      put do
        result = UpdateStore.phenotypes(params)
        json(conn, result)
      end
    end
  end
end
