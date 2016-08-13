defmodule GnServer.Router.Biodalliance.Stylesheets do

  use Maru.Router
  plug CORSPlug, origin: ["*"], headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  namespace :stylesheets do
    route_param :file, type: String do

      get do
        path = "./templates/biodalliance/" <> params[:file]

        conn
        |> put_resp_content_type("application/xml")
        |> send_file(200, path)
        |> halt
      end

    end
  end
end
