defmodule GnServer.Router.GnExec do
  use Maru.Router

  IO.puts "Setup routing for GnExec REST APIs"

# WIP: run scanone
  get "qtl/scanone/iron.json" do
    result = GnExec.Cmd.ScanOne.cmd("iron")
    # IO.inspect(result)
    json(conn, result)
  end

  # WIP: run pylmm
  get "/qtl/pylmm/iron.json" do
    {retval,token} = GnExec.Cmd.PyLMM.cmd("iron")
    json(conn, %{ "retval": retval, "token": token})
  end

  get do
    version = Application.get_env(:gn_server, :version)
    json(conn, %{"I am": :genenetwork, "version": version })
  end

  get "/hey" do
    version = Application.get_env(:gn_server, :version)
    json(conn, %{"I am": :genenetwork, "version": version })
  end

  # namespace :gnexec do
    namespace :program do
      route_param :token, type: String do
        get "status.json" do
          static_path = Application.get_env(:gn_server, :static_path_prefix)
          status_path = Path.join(static_path, params[:token])
          status = case File.exists?(status_path) do
            false -> %{error: :invalid_token}
            true ->
              status_path_file = Path.join(status_path, "status.json")
              Poison.Parser.parse!(File.read!(status_path_file),keys: :atoms!)
          end
          json(conn, status)
        end

        desc "Update a status"
        params do
          requires :progress, type: Integer
        end
        put "status.json" do
          IO.puts params[:token]
          IO.puts params[:progress]
          json(conn, %{token: params[:token], progress: params[:progress] })
        end

        get "results.json" do
        end

        get "STDOUT" do
        end
      end

    end
    route_param :command, type: String do
      get "dataset.json" do
        static_path = Application.get_env(:gn_server, :static_path_prefix)
        case GnExec.Rest.Job.validate(params[:command]) do
          {:error, :noprogram } -> json(conn, %{error: :noprogram})
          {:ok, module } ->
            job = GnExec.Rest.Job.new(params[:command], ["."])
            path = Path.join(static_path, job.token)
            File.mkdir_p(path)
            File.touch!(Path.join(path,"STDOUT"))
            File.touch!(Path.join(path,"status.json"))
            json(conn, job)
        end
      end

    end
  # end # gnexec
end
