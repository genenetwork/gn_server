defmodule GnServer.Router.Main do
  use Maru.Router

  IO.puts "Setup routing"

  alias GnServer.Data.Store, as: Store
  alias GnServer.Logic.Assemble, as: Assemble

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

  namespace :phenotype do
    route_param :dataset, type: String do
      route_param :group, type: String do
        route_param :trait, type: String do
          get do
            { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
              [_,trait] = Regex.run ~r/(.*)\.json$/, params[:trait]
              Store.phenotype_info(params[:dataset],trait,params[:group])
            end)
            json(conn, result)
          end
        end
      end
    end
  end

  namespace :phenotype do
    route_param :dataset, type: String do
      route_param :trait, type: String do
        get do
          { status, result } = Cachex.get(:gn_server_cache, conn.request_path, fallback: fn(key) ->
            [_,trait] = Regex.run ~r/(.*)\.json$/, params[:trait]
            Store.phenotype_info(params[:dataset],trait)
          end)
          json(conn, result)
        end
      end
    end
  end

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

  get do
    version = Application.get_env(:gn_server, :version)
    json(conn, %{"I am": :genenetwork, "version": version })
  end

  get "/hey" do
    version = Application.get_env(:gn_server, :version)
    json(conn, %{"I am": :genenetwork, "version": version })
  end

end
