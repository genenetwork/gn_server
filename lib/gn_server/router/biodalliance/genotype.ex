defmodule GnServer.Router.Biodalliance.Genotype do

  use Maru.Router
  plug CORSPlug, origin: ["*"], headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  namespace :genotype do

    namespace :mouse do

      route_param :cross, type: String do

        params do
          requires :file,       type: String
          optional :chr,        type: String
          optional :start,      type: Float
          optional :end,        type: Float
        end

        get do
          # this should probably be done in a... better way.
          path = "./test/data/input/genotype/" <> params[:cross] <> "_" <> params[:file] <> ".csv"

          conn
          |> GnServer.Files.serve_file(path, "text/csv", 206)
        end
      end
    end
  end
end