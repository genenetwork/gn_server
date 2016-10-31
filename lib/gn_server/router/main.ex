defmodule GnServer.Router.Main do
  use Maru.Router

  IO.puts "Setup routing"

  alias GnServer.Data.Store, as: Store
  alias GnServer.Logic.Assemble, as: Assemble

  # ==== Some private helper functions

  @doc """
  Convenience function transforms a string into an integer
  value when it can actually convert to int. Otherwise it leaves it as
  a string. Returns tuple {:string, s} or {:integer, i} tuple with
  type descriptor and value.
  """

  defp integer_or_string(id) do
    try do
      { :integer, String.to_integer(id) }
    rescue
      _ in ArgumentError -> { :string, id }
    end
  end

  # ==== Routing

  get "/species" do
    { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
      Store.species
    end)
    json(conn, result)
  end

  namespace :groups do
    route_param :species, type: String do
      get do
        { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
          Store.groups(params[:species])
        end)
        json(conn, result)
      end
    end
  end

  namespace :group do
    route_param :name, type: String do
      get do
        { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
           [_,group] = Regex.run ~r/(.*)\.json$/, params[:name]
           Assemble.group_info(group)
        end)
        json(conn, result )
      end
    end
  end

  namespace :cross do
    route_param :name, type: String do
      get do
        { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
          [_,group] = Regex.run ~r/(.*)\.json$/, params[:name]
          Assemble.group_info(group)
        end)
        json(conn, result)
      end
    end
  end

  namespace :datasets do
    route_param :group, type: String do
      get do
        { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
          Store.datasets(params[:group])
        end)
        json(conn, result)
      end
    end
  end

  namespace :dataset do
    route_param :dataset_name, type: String do
      get do
        { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
          [_,dataset_name] = Regex.run ~r/(.*)\.json$/, params[:dataset_name]
          Assemble.dataset_info(dataset_name)
        end)
        json(conn, result)
      end
    end
  end

  namespace :trait do
    route_param :dataset, type: String do
      route_param :trait, type: String do
        get do
          { int_or_string, dataset } = integer_or_string(params[:dataset])
          [_,trait,type] = Regex.run ~r/(.*)\.(json|csv)$/, params[:trait]
          { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
            Store.trait(dataset,trait)
          end)
          case type do
            "json" -> json(conn, result)
            "csv"  ->
                      res = result |> Enum.map(fn r -> [id,_,v,_] = r; "#{id},#{v}" end)
                      conn |> text( "id,value\n" <> Enum.join(res,"\n"))
          end
        end
      end
    end
  end

  # /trait/HC_M2_0606_P/BXD/1443823_s_at.json
  namespace :trait do
    route_param :dataset, type: String do
      route_param :group, type: String do
        route_param :trait, type: String do
          get do
            { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
              [_,trait] = Regex.run ~r/(.*)\.json$/, params[:trait]
              Store.trait(params[:dataset],trait,params[:group])
            end)
            json(conn, result)
          end
        end
      end
    end
  end

  # /trait/HC_U_0304_R/104617_at.json
  # /trait/HC_U_0304_R/104617_at.csv
  # /trait/112/1443823_s_at.json
  # /trait/112/1443823_s_at.csv
  namespace :trait do
    route_param :dataset, type: String do
      route_param :trait, type: String do
        get do
          { int_or_string, dataset } = integer_or_string(params[:dataset])
          [_,trait,type] = Regex.run ~r/(.*)\.(json|csv)$/, params[:trait]
          { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
            Store.trait(dataset,trait)
          end)
          case type do
            "json" -> json(conn, result)
            "csv"  ->
                      res = result |> Enum.map(fn r -> [id,_,v,_] = r; "#{id},#{v}" end)
                      conn |> text( "id,value\n" <> Enum.join(res,"\n"))
          end
        end
      end
    end
  end

  # /trait/CBLDT2.json
  # /trait/CBLDT2.csv
  # /trait/10001.json
  # /trait/10001.csv
  namespace :trait do
    route_param :dataset, type: String do
      get do
        [_,dataset,type] = Regex.run ~r/(.*)\.(json|csv)$/, params[:dataset]
        { int_or_string, dataset } = integer_or_string(dataset)
        { status, result } = Cachex.get(:gn_server_cache, conn.request_path,
          fallback: fn(key) ->
            Store.trait(dataset)
          end)
        case type do
          "json" -> json(conn, result)
          "csv"  ->
            res = result |> Enum.map(fn r -> [id,_,v,_] = r; "#{id},#{v}" end)
            conn |> text( "id,value\n" <> Enum.join(res,"\n"))
        end
      end
    end
  end

  namespace :phenotypes do
    route_param :dataset_name, type: String do
      params do
        optional :start, type: Integer
        optional :stop, type: Integer
      end
      get do
        { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
          [_,dataset_name] = Regex.run ~r/(.*)\.json$/, params[:dataset_name]
          Store.phenotypes(dataset_name,params[:start],params[:stop])
        end)
        json(conn, result)
      end
    end
  end

  plug CORSPlug, origin: ["*"], headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  static_path_prefix = Application.get_env(:gn_server, :static_path_prefix)
  plug Plug.Static, at: "genotype/", from: static_path_prefix <> "/genotype"

  namespace :genotype do
    route_param :species, type: String do
      namespace :marker do
        route_param :marker, type: String do
          get do
            { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
              [_,marker] = Regex.run ~r/(.*)\.json$/, params[:marker]
              Store.marker_info(params[:species],marker)
            end)
            json(conn, result)
          end
        end
      end
    end
  end

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

end
