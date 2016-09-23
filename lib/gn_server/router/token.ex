defmodule GnServer.Router.Token do

  use Maru.Router

  IO.puts "Setup token generation routing"

  namespace :submit do

    namespace :get_token do

      params do
        requires :tokenid, type: String
      end

      post do
        IO.puts params[:tokenid]
        digest = :crypto.hash(:sha256, params[:tokenid])
        |> Base.url_encode64

        IO.inspect digest

        path = Application.get_env(:gn_server, :upload_dir)
        |> Path.join(digest)

        unless File.exists?(path) do
          IO.puts "creating token directory"
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
