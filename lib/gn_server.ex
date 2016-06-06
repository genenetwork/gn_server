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
          {:ok, content} = File.read("./genotype/" <> params[:cross] <> "_" <> params[:file] <> ".csv" )

          len = byte_size(content)

          conn
          |> put_resp_header("Content-Range", "bytes 0-" <> (to_string(len-1)) <> "/" <> to_string(len))
          |> put_resp_header("Accept-Ranges", "bytes")
          |> put_resp_content_type("text/csv")
          |> send_resp(206, content)
        end

      end
    end

  end

end

defmodule GnServer.API do
  use Maru.Router


  mount GnServer.Router.Homepage
  mount GnServer.Router.Rqtl

  IO.puts "Starting server"
  
  rescue_from :all, as: e do
    IO.inspect e

    conn
    |> put_status(500)
    |> text("Server error")
  end

end
