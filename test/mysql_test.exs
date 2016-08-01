defmodule MySQLTest do
  use ExUnit.Case

  # We currently use the small database for testing
  test "Test MySQL connection" do
    settings = Application.get_env(:gn_server, GnServer.Repo)
    {:ok, pid} = Mysqlex.Connection.start_link(username:
      settings[:username], database: settings[:database],
      password: settings[:password], hostname: settings[:hostname])
    {:ok, result} =
      Mysqlex.Connection.query(pid, "SELECT * FROM Species", [])

    %Mysqlex.Result{rows: rows} = result
    nlist = Enum.map(rows, fn(x) -> {_,_,s,_,_,_,_,_} = x ; s end)
    assert length(nlist) == 2 end

end
