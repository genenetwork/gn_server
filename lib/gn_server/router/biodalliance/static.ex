defmodule GnServer.Router.Biodalliance.Static do
  use Maru.Router

  plug CORSPlug, origin: ["*"], headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  plug GnServers.Headers.CORSRangePlug

  uri = Application.get_env(:gn_server, :static_uri)
  local_path = Application.get_env(:gn_server, :static_path)
  plug Plug.Static, at: uri, from: local_path
end
