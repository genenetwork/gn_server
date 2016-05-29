defmodule GnServer.Router.Homepage do

  use Maru.Router

  IO.puts "Setup routing"

  alias GnServer.Data.Store, as: Store

  # DB_URI = "mysql://gn2:mysql_password@localhost/db_webqtl_s"
  get "/species" do
    # CSV version: text(conn,Enum.join(nlist,"\n"))
    json(conn, Store.species)
  end

  get do
    json(conn, %{"I am": :genenetwork})
  end

  get "/hey" do
    json(conn, %{"I am": :genenetwork})
  end

end

defmodule GnServer.API do
  use Maru.Router

  mount GnServer.Router.Homepage

  IO.puts "Starting server"
  
  rescue_from :all, as: e do
    IO.inspect e

    conn
    |> put_status(500)
    |> text("Server error")
  end

end
