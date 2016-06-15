defmodule GnServer.Files do
  use Maru.Router
  plug CORSPlug, origin: ["*"], headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  def serve_file(conn, path, content_type, status) do
    {:ok, content} = File.read(path)
    len = byte_size(content)
    {content, len}
    conn
    |> GnServer.Headers.add_cors_header(len)
    |> put_resp_content_type(content_type)
    |> send_resp(status, content)
  end
end
