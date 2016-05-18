
defmodule GnServer.Router.Homepage do
  use Maru.Router

  get "/hey2" do
    {:ok, pid} = Mysqlex.Connection.start_link(username: "test", database: "test", password: "test", hostname: "localhost")
    {:ok, result} = Mysqlex.Connection.query(pid, "SELECT title FROM posts", [])
    # rec = Map.from_struct(result)
    # lines = rec[:rows]
    %Mysqlex.Result{rows: rows} = result
    # IO.inspect(rows)
    nlist = Enum.map(rows, fn(x) -> {s} = x ; s end)
    # IO.puts Poison.encode_to_iodata!(nlist)
    json(conn, nlist)
  end

  get "/hey.csv" do
    {:ok, pid} = Mysqlex.Connection.start_link(username: "test", database: "test", password: "test", hostname: "localhost")
    {:ok, result} = Mysqlex.Connection.query(pid, "SELECT title FROM posts", [])
    # rec = Map.from_struct(result)
    # lines = rec[:rows]
    %Mysqlex.Result{rows: rows} = result
    # IO.inspect(rows)
    nlist = Enum.map(rows, fn(x) -> {s} = x ; s end)
    text(conn,Enum.join(nlist,"\n"))
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
  rescue_from :all do
    conn
    |> put_status(500)
    |> text("*** Server Error")
  end
end
