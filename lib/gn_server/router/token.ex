defmodule GnServer.Router.Token do

  use Maru.Router

  IO.puts "Setup token generation routing"

  # curl -X POST -d userid="test" -d tokenid=messagexll http://127.0.0.1:8880/submit/get_token

  namespace :submit do

    namespace :get_token do

      params do
        requires :userid, type: String
        requires :tokenid, type: String
      end

      post do
        digest = :crypto.hash(:sha256, [params[:userid], params[:tokenid]])
        |> Base.url_encode64

        IO.inspect digest

        path = Application.get_env(:gn_server, :upload_dir)
        |> Path.join(digest)

        unless File.exists?(path) do
          IO.puts "creating token directory", path
          File.mkdir_p(path)
          conn
          |> put_status(201)
          |> text(digest)
        else
          conn
          |> put_status(200)
          |> text(digest)
        end

      end
    end
  end
end
