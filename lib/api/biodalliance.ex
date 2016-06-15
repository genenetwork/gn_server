defmodule GnServer.Router.Genotype do

  use Maru.Router
  plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  namespace :genotype do

    namespace :mouse do

      route_param :cross, type: String do

        params do
          requires :file,       type: String
          optional :chr,        type: String
          optional :start,      type: Float
          optional :end, 				type: Float
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

defmodule GnServer.Router.QTL do

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

defmodule GnServer.Router.SNP do

  use Maru.Router
  plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  namespace :snp do
    route_param :file, type: String do

      # params do
      # optional :chr,        type: String
      # optional :start,      type: Float
      # optional :end, 				type: Float
      # end

      get do
        # IO.inspect params[:file]
        path = "./test/data/input/snptest/" <> params[:file]

        conn
        |> GnServer.Files.serve_file(path, "application/x-gzip", 206)
      end
    end
  end
end

defmodule GnServer.Router.Stylesheets do

  use Maru.Router
  plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  namespace :stylesheets do
    route_param :file, type: String do

      get do
        path = "./templates/biodalliance/" <> params[:file]

        conn
        |> GnServer.Files.serve_file(path, "application/xml", 200)
      end

    end
  end
end
