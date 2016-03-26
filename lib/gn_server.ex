
defmodule GnServer.Router.Homepage do
  use Maru.Router

  get "/hey" do
    {:ok, pid} = Mysqlex.Connection.start_link(username: "test", database: "test", password: "test", hostname: "localhost")
    {:ok, result} = Mysqlex.Connection.query(pid, "SELECT title FROM posts", [])
    rec = Map.from_struct(result)
    IO.puts :stderr, "HERE"
    lines = rec[:rows]
    for item <- lines do
      {s} = item
      IO.puts s
    end
    IO.inspect(Enum.join(lines))
    # Enum.join(tuple_to_list(lines))
    json(conn, lines.first)
  end
  get do
      json(conn, %{hello: :world})
  end

end

defmodule GnServer.API do
  use Maru.Router
  
  mount GnServer.Router.Homepage
  IO.puts "HELLO"

    {:ok, pid} = Mysqlex.Connection.start_link(username: "test", database: "test", password: "test", hostname: "localhost")

    {:ok, result} = Mysqlex.Connection.query(pid, "SELECT title FROM posts", [])
    rec = Map.from_struct(result)
    lines = rec[:rows]
    for item <- lines do
      {s} = item
      IO.puts s
    end
    IO.inspect(lines)

  rescue_from :all do
    conn
    |> put_status(500)
    |> text("*** Server Error")
  end
end
