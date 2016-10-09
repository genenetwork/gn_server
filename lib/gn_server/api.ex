defmodule GnServer.API do
  use Maru.Router, opt_app: :gn_server

  plug Plug.Head

  mount GnServer.Router.Main
  mount GnServer.Router.Internal
  mount GnServer.Router.Submit
  mount GnServer.Router.Token
  mount GnServer.Router.Download
  mount GnServer.Router.Biodalliance.Genotype
  mount GnServer.Router.Biodalliance.SNP
  mount GnServer.Router.Biodalliance.Stylesheets
  mount GnServer.Router.Biodalliance.QTL
  mount GnServer.Router.Biodalliance.Static
  mount GnServer.Router.GnExec 

  IO.puts "Starting server"

  rescue_from :all, as: e do
    IO.inspect e

    conn
    |> put_status(500)
    |> text("Server error")
  end

end
