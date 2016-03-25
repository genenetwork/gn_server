
defmodule GnServer.Router.Homepage do
    use Maru.Router

    get "/hey" do
      json(conn, %{hello: :hey})
    end
    get do
      json(conn, %{hello: :world})
    end
end

defmodule GnServer.API do
    use Maru.Router

    mount GnServer.Router.Homepage

    rescue_from :all do
      conn
      |> put_status(500)
      |> text("*** Server Error")
    end
end
