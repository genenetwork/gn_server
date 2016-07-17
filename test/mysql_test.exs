defmodule MySQLTest do
  use ExUnit.Case

  # We currently use the small database for testing
  test "Test MySQL connection" do
    db_settings = Application.get_env(:gn_server, GnServer.Repo)
    [adapter: Ecto.Adapters.MySQL, database: database, username: username,
       password: password, hostname: hostname, pool_size: 20] = db_settings

    {:ok, pid} = Mysqlex.Connection.start_link(username: username, database: database, password: password, hostname: hostname)
    {:ok, result} = Mysqlex.Connection.query(pid, "SELECT * FROM Species", [])
    %Mysqlex.Result{rows: rows} = result
    nlist = Enum.map(rows, fn(x) -> {_,_,s,_,_,_,_,_} = x ; s end)
    assert length(nlist) == 2
  end

end
