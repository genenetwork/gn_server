defmodule GnServer.API do
  use Maru.Router
  
  plug CORSPlug, origin: ["*"]
  plug Plug.Head

  mount GnServer.Router.MainAPI
  mount GnServer.Router.IntAPI
  mount GnServer.Router.Genotype
  mount GnServer.Router.SNP
  mount GnServer.Router.Stylesheets
  mount GnServer.Router.QTL

  IO.puts "Starting server"
  
  rescue_from :all, as: e do
    IO.inspect e

    conn
    |> put_status(500)
    |> text("Server error")
  end

end
