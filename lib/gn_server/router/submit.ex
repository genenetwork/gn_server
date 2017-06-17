# Contains the data submission routes

defmodule GnServer.Router.Submit do

  use Maru.Router
  # plug CORSPlug, origin: ["*"]

  IO.puts "Setup submit routing"

  alias GnServer.Data.UpdateStore, as: UpdateStore
  # alias GnServer.Logic.Assemble, as: Assemble

  # Test with:
  #   echo -e -n "hello world" |curl -X PUT -d @- -d message=test -d message=message http://127.0.0.1:8880/echo
  namespace :echo do
    params do
      # requires :tokenid, type: String
      optional :message, type: String
    end
    put do
      body2 = for {k, v} <- conn.params, v == nil, into: [], do: k
      body = List.first(body2)
      result = UpdateStore.echo(params,body)
      json(conn, result)
    end
  end

  namespace :submit do
    namespace :phenotypes do
      params do
        # requires :tokenid, type: String
        optional :dataset, type: String
      end
      put do
        result = UpdateStore.phenotypes(params)
        json(conn, result)
      end
    end

    # Upload a file
    # curl -X POST -d userid="test" -d tokenid=messagexll http://127.0.0.1:8880/submit/get_token
    #    4PmJfVN7HBXD4_Py0tf8K1a_OPPoZhIXphpSlcOIuN4
    #
    # echo "TEST" |curl -X PUT -d @- -d filename="test" -d token="4PmJfVN7HBXD4_Py0tf8K1a_OPPoZhIXphpSlcOIuN4=" http://127.0.0.1:8880/submit/rqtl/control

    namespace :rqtl do
      namespace :control do
        params do
          requires :token, type: String
          requires :filename, type: String
        end

        put do
          alias GnServer.Logic.Token, as: Token
          # {:ok, data, _} = conn |> read_body
          body2 = for {k, v} <- conn.params, v == nil, into: [], do: k
          data = List.first(body2)
          case conn.params["token"] |> Token.validate_token do
            {:valid, token} ->
              path = Application.get_env(:gn_server, :upload_dir)
              |> Path.join(token) |> Path.join(conn.params["filename"])
              IO.puts "writing to " <> path
              {:ok, file} = File.open(path, [:write])
              file
              |> IO.binwrite(data)
              |> File.close
              result = %{"submit" => "ok"}
              conn
              |> put_status(200)
              |> json(result)
            {:invalid} ->
              IO.puts "invalid token!"
              conn
              |> put_status(403)
              |> json(%{"submit" => "ERROR: invalid token"})
          end
        end
      end
    end

    namespace :geno do
      post do

        alias GnServer.Logic.Geno2Rqtl, as: Geno2Rqtl
        alias GnServer.Logic.Token, as: Token

        {:ok, data, _} = conn |> read_body

        # TODO the parameters should probably be handled in a better way
        filename = conn.params["filename"]

        case conn.params["token"] |> Token.validate_token do
          {:valid, token} ->
            IO.puts "creating path"
            # TODO configurable path
            path = Path.join("/var/tmp/gn_server/", conn.params["filename"])
            IO.puts "opening file"
            {:ok, file} = File.open(path, [:write])

            IO.puts "writing to file"
            file
            |> IO.binwrite(data)
            |> File.close
            IO.puts "wrote to file"

            IO.puts "transforming file"
            out_path = Application.get_env(:gn_server, :upload_dir)
            |> Path.join(token)

            case Geno2Rqtl.transform_file(path, out_path) do
              {:ok, control_name} ->
                # TODO transform control file path to externally visible URL
                url = control_name
                conn
                |> put_status(200)
                |> text(Path.join(token, url))
              _ ->
                # TODO better & more specific errors
                conn
                |> put_status(500)
                |> text("error transforming file to rqtl")
            end

          {:invalid} ->
            IO.puts "invalid token!"

            conn
            |> put_status(403)
            |> text("invalid auth token")
        end
      end
    end
  end
end
