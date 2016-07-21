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
      case File.stat("." <> conn.request_path) do
        {:ok, %{size: size}} ->
          conn
          |> Plug.Conn.put_resp_header("Content-Range", "bytes 0-#{size-1}/#{size}")
        {:error, e} ->
          IO.puts("CORSRangePlug error " <> to_string(e))
          conn
      end
    end
  end
end
