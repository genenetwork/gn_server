defmodule MySQLTest do
  use ExUnit.Case
  # doctest GnServer

  # We currently use the small database for testing
  test "Test MySQL connection" do
    # {:ok, settings} = Poison.decode(File.read!("./etc/test_settings.json"))
    # db_settings = settings["db"]
    db_settings = Application.get_env(:gn_server, GnServer.Repo)
    [adapter: Ecto.Adapters.MySQL, database: database, username: username,
       password: password, hostname: hostname, pool_size: 20] = db_settings

    {:ok, pid} = Mysqlex.Connection.start_link(username: username, database: database, password: password, hostname: hostname)
    {:ok, result} = Mysqlex.Connection.query(pid, "SELECT * FROM Species", [])
    # rec = Map.from_struct(result)
    %Mysqlex.Result{rows: rows} = result
    # IO.inspect(rows)
    nlist = Enum.map(rows, fn(x) -> {_,_,s,_,_,_,_,_} = x ; s end)
    # IO.puts Poison.encode_to_iodata!(nlist)
    # IO.puts Enum.join(nlist,"\n")
    assert length(nlist) == 2
  end

end
