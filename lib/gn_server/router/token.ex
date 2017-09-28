defmodule GnServer.Router.Token do

  use Maru.Router # , make_plug: true

  IO.puts "Setup token generation routing"

  # plug Plug.Parsers, [
  #   parsers: [Plug.Parsers.URLENCODED, Plug.Parsers.JSON, Plug.Parsers.MULTIPART],
  #   pass: ["*/*"],
  #   json_decoder: Poison
  # ]

  # not working curl -X POST -d userid="test" -d projectid=Yes http://127.0.0.1:8880/token/get
  # works curl -X POST "http://127.0.0.1:8880/token/get?userid=pj&projectid=2"

  # use Maru.Builder

  namespace :token do

    params do
      optional :userid, type: String
      # requires :projectid, type: String
    end

    post :get do

      IO.inspect(conn)
        conn = Plug.Conn.fetch_query_params(conn)
        IO.inspect(conn.params)
        params = conn.params
        IO.inspect("!!!!!!!!!!!!!!token/get")
        digest = GnServer.Logic.Token.compute_token([params["userid"], params["projectid"]])
        # digest = GnServer.Logic.Token.compute_token("teost")
        IO.puts "Computed token" <> digest

        path = Application.get_env(:gn_server, :upload_dir)
        |> Path.join(digest)

        unless File.exists?(path) do
          IO.puts "Creating token directory " <> path
          File.mkdir_p(path)
          conn
          |> put_status(201)
          |> text(digest)
        else
          IO.puts "Found token directory " <> path
          conn
          |> put_status(200)
          |> text(digest)
        end

      end
    end

    namespace :remove do
      route_param :token, type: String do
        params do
          requires :userid, type: String
          requires :projectid, type: String
        end

        post do
          digest = GnServer.Logic.Token.compute_token([params[:userid], params[:projectid]])

          token = params[:token]
          path = Application.get_env(:gn_server, :upload_dir)
          |> Path.join(token)

          if File.exists?(path) and digest == token do
            filenames = Path.wildcard(path <> "/*")
            Enum.each filenames, fn(filen) ->
              IO.puts "Removing " <> filen
              File.rm! filen
            end
            IO.puts "Removing " <> path
            File.rm_rf! path
            conn
            |> put_status(200)
            |> json([:ok])
          else
            IO.puts "Path not found " <> path
            conn
            |> put_status(404)
          end
        end
      end
    end

end
