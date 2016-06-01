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

  namespace :rqtl do

    params do
      requires :file, type: String
    end
    get do
      # TODO needs to handle nonexistent files
      {:ok, content} = File.read("./" <> params[:file])

      conn
      |> Plug.Conn.put_resp_header("Access-Control-Allow-Origin", "*")
      |> Plug.Conn.put_resp_header("Access-Control-Expose-Headers", "Content-Range")
      |> text(content)
    end

    options do
      conn
      |> Plug.Conn.put_resp_header("Access-Control-Allow-Origin", "*")
      |> Plug.Conn.put_resp_header("Access-Control-Allow-Headers", "Range,If-None-Match,Content-Range")
      |> Plug.Conn.put_resp_header("Access-Control-Allow-Methods", "GET, OPTIONS")
      |> text("")
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
