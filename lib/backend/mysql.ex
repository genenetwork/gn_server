defmodule GnServer.Backend.MySQLinfo do
  defstruct user: "gn2",
    password: "mysql_password", type: nil
end

defmodule GnServer.Backend.MySQL do

  info = %GnServer.Backend.MySQLinfo{}
  IO.inspect info

  def query(str) do
    {:ok, pid} = Mysqlex.Connection.start_link(username: "gn2", database: "db_webqtl_s", password: "mysql_password", hostname: "localhost")
    {:ok, result} = Mysqlex.Connection.query(pid, str)
    # rec = Map.from_struct(result)
    %Mysqlex.Result{rows: rows} = result
    rows
  end
end
