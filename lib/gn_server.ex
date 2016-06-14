defmodule GnServer.Router.Homepage do

  use Maru.Router

  IO.puts "Setup routing"

  alias GnServer.Data.Store, as: Store

  get "/species" do
    # CSV version: text(conn,Enum.join(nlist,"\n"))
    json(conn, Store.species)
  end

  get "/datasets" do
    json(conn, Store.datasets)
  end

  get do
    json(conn, %{"I am": :genenetwork})
  end

  get "/hey" do
    json(conn, %{"I am": :genenetwork})
  end

end

defmodule GnServer.Router.Rqtl do

  use Maru.Router

  namespace :genotype do

    namespace :mouse do

      route_param :cross, type: String do

        plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

        params do
          requires :file,       type: String
          optional :chr,        type: String
          optional :start,      type: Float
          optional :end, 				type: Float
        end

        get do
          # this should probably be done in a... better way.
          path = "./genotype/" <> params[:cross] <> "_" <> params[:file] <> ".csv"

          conn
          |> GnServer.Utility.serve_file(path, "text/csv", 206)
        end
      end
    end
  end
end

defmodule GnServer.Router.QTL do

  use Maru.Router
  namespace :qtl do
    route_param :file, type: String do
      plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

      get do
        path = "./qtl/" <> params[:file]

        conn
        |> GnServer.Utility.serve_file(path, "text/csv", 206)
      end
    end
  end
end

defmodule GnServer.Router.SNP do

  use Maru.Router

  namespace :snp do
    route_param :file, type: String do
      plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

      # params do
      # optional :chr,        type: String
      # optional :start,      type: Float
      # optional :end, 				type: Float
      # end

      get do
        IO.inspect params[:file]
        path = "./snptest/" <> params[:file]

        conn
        |> GnServer.Utility.serve_file(path, "application/x-gzip", 206)
      end
    end
  end
end

defmodule GnServer.Router.Stylesheets do

  use Maru.Router

  namespace :stylesheets do
    route_param :file, type: String do
      plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

      get do
        path = "./bd-stylesheets/" <> params[:file]

        conn
        |> GnServer.Utility.serve_file(path, "application/xml", 200)
      end

    end
  end
end

defmodule GnServer.Utility do
  use Maru.Router

  def add_cors_header(c, len) do
    c
    |> put_resp_header("Content-Range", "bytes 0-" <> (to_string(len-1)) <> "/" <> to_string(len))
    |> put_resp_header("Accept-Ranges", "bytes")
  end

  def serve_file(conn, path, content_type, status) do
    {:ok, content} = File.read(path)
    len = byte_size(content)
    {content, len}
    conn
    |> add_cors_header(len)
    |> put_resp_content_type(content_type)
    |> send_resp(status, content)
  end
end

defmodule GnServer.API do
  use Maru.Router


  mount GnServer.Router.Homepage
  mount GnServer.Router.Rqtl
  mount GnServer.Router.SNP
  mount GnServer.Router.Stylesheets

  IO.puts "Starting server"
  
  rescue_from :all, as: e do
    IO.inspect e

    conn
    |> put_status(500)
    |> text("Server error")
  end

end
