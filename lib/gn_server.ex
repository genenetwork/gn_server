defmodule GnServer.Router.Homepage do

  use Maru.Router

  IO.puts "Setup routing"

  alias GnServer.Backend.MySQL, as: DB

  # DB_URI = "mysql://gn2:mysql_password@localhost/db_webqtl_s"
  get "/species" do
    rows = DB.query("SELECT * FROM Species")
    nlist = Enum.map(rows, fn(x) -> {_,species_id,species_name,_,_,full_name,_,_} = x ; [species_id,species_name,full_name] end)
    IO.puts Poison.encode_to_iodata!(nlist)
    IO.puts Enum.join(nlist,"\n")
    # CSV version: text(conn,Enum.join(nlist,"\n"))
    json(conn, nlist)
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
