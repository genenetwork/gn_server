defmodule GnServer.Router.Biodalliance.QTL do

  use Maru.Router
  plug CORSPlug, origin: ["*"], headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]
  plug GnServers.Headers.CORSRangePlug

  namespace :qtl do
    route_param :file, type: String do

      get do
        path = "./test/data/input/qtl/" <> params[:file]

        GnServer.Files.serve_csv_partial(conn, path)
      end
    end
  end
end
