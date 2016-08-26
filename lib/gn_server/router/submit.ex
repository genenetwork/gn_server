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
      body2 = for {k, v} <- conn.params, v == nil, into: [], do: k
      body = List.first(body2)
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
