defmodule GnServer.Headers do
  use Maru.Router

  def add_cors_header(c, len) do
    c
    |> put_resp_header("Content-Range", "bytes 0-" <> (to_string(len-1)) <> "/" <> to_string(len))
    |> put_resp_header("Accept-Ranges", "bytes")
  end

end
