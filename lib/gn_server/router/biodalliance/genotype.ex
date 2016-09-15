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
          path = "./test/data/input/genotype/#{params[:cross]}_#{params[:file]}.csv"

          GnServer.Files.serve_csv_partial(conn, path)
        end
      end
    end
  end
end
