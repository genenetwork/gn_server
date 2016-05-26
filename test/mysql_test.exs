defmodule MySQLTest do
  use ExUnit.Case
  # doctest GnServer

  # DB_URI = "mysql://gn2:mysql_password@localhost/db_webqtl_s"
  test "Test MySQL connection" do
    {:ok, pid} = Mysqlex.Connection.start_link(username: "gn2", database: "db_webqtl_s", password: "mysql_password", hostname: "localhost")
    {:ok, result} = Mysqlex.Connection.query(pid, "SELECT * FROM Species", [])
    # rec = Map.from_struct(result)
    %Mysqlex.Result{rows: rows} = result
    IO.inspect(rows)
    nlist = Enum.map(rows, fn(x) -> {_,_,s,_,_,_,_,_} = x ; s end)
    IO.puts Poison.encode_to_iodata!(nlist)
    IO.puts Enum.join(nlist,"\n")
    assert length(nlist) == 2
  end
end
