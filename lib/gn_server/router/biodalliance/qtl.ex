defmodule GnServer.Router.Biodalliance.QTL do

  use Maru.Router
  plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]
  namespace :qtl do
    route_param :file, type: String do

      get do
        path = "./test/data/input/qtl/" <> params[:file]

        conn
        |> GnServer.Files.serve_file(path, "text/csv", 206)
      end
    end
  end
end