defmodule GnServer.Backend.MySQLinfo do
  defstruct database: "db_webqtl_s", user: "gn2",
    password: "mysql_password", hostname: "localhost"
end

defmodule GnServer.Backend.MySQL do
  # At this point we start a connection every time. We are planning
  # for query caching as well as connection pooling for short
  # queries. Long running queries should not use a pool to avoid
  # blocking.

  # Query the database and return rows
  def query(str) do
    db = %GnServer.Backend.MySQLinfo{}
    {:ok, pid} = Mysqlex.Connection.start_link(username: db.user, database: db.database, password: db.password, hostname: db.hostname)
    {:ok, result} = Mysqlex.Connection.query(pid, str)
    # rec = Map.from_struct(result)
    %Mysqlex.Result{rows: rows} = result
    {:ok, rows}
  end
end
