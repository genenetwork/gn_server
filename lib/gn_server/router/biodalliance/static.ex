defmodule GnServer.Router.Biodalliance.Static do
  use Maru.Router

  plug CORSPlug, origin: ["*"], headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  plug GnServers.Headers.CORSRangePlug

  uri = "static/"
  static_path_prefix = Application.get_env(:gn_server, :static_path_prefix)
  plug Plug.Static, at: uri, from: static_path_prefix
end
