defmodule GnServer.Router.Download do
  use Maru.Router

  plug CORSPlug, origin: ["*"], headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  path = Application.get_env(:gn_server, :upload_dir)
  plug Plug.Static, at: "download/", from: path

end
