defmodule GnServer.Router.Biodalliance.Stylesheets do

  use Maru.Router
  plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  namespace :stylesheets do
    route_param :file, type: String do

      get do
        path = "./templates/biodalliance/" <> params[:file]

        conn
        |> GnServer.Files.serve_file(path, "application/xml", 200)
      end

    end
  end
end
