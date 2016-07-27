defmodule GnServer.Files do
  use Maru.Router

  alias GnServers.Headers.CORSRangePlug, as: CORSRange

  def serve_csv_partial(conn, path) do
    %{size: size} = File.stat!(path)

    conn
    |> CORSRange.put_content_range(0, size-1, size)
    |> put_resp_header("content-type", "text/csv")
    |> send_file(206, path)
    |> halt
  end
end
