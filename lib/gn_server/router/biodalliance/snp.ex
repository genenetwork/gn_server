defmodule GnServer.Router.Biodalliance.SNP do

  use Maru.Router
  plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  namespace :snp do
    route_param :file, type: String do

      # params do
      # optional :chr,        type: String
      # optional :start,      type: Float
      # optional :end,        type: Float
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