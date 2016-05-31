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

  get "/iron.json" do
    {:ok, content} = File.read("./iron.json")
    text(conn, content)
  end

  get "/iron_gmap.csv" do
    {:ok, content} = File.read("./iron_gmap.csv")
    text(conn, content)
  end

  get "/iron_geno.csv" do
    {:ok, content} = File.read("./iron_geno.csv")
    text(conn, content)
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
