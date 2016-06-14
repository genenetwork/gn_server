

defmodule GnServer.API do
  use Maru.Router

  mount GnServer.Router.MainAPI
  mount GnServer.Router.IntAPI
  mount GnServer.Router.Rqtl
  mount GnServer.Router.SNP
  mount GnServer.Router.Stylesheets

  IO.puts "Starting server"
  
  rescue_from :all, as: e do
    IO.inspect e

    conn
    |> put_status(500)
    |> text("Server error")
  end

end
