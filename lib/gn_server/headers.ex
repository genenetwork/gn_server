defmodule GnServers.Headers.CORSRangePlug do
  @behaviour Plug
  @allowed_methods ~w(GET HEAD)

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if (Enum.empty?(Plug.Conn.get_req_header(conn, "range"))) do
      conn
    else
      static_prefix = Application.get_env(:gn_server, :static_path_prefix)
      path = static_prefix <> String.replace_prefix(conn.request_path, "/static", "")
      case File.stat(path) do
        {:ok, %{size: size}} ->
          conn
          |> put_content_range(0, size-1, size)
        {:error, e} ->
          IO.puts("CORSRangePlug error " <> to_string(e) <> " - " <> path)
          conn
      end
    end

  end

  def put_content_range(conn, start, stop, size) do
    conn
    |> Plug.Conn.put_resp_header("content-range", "bytes #{start}-#{stop}/#{size}")
  end
end
