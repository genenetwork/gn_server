defmodule GnServer.Router.MainAPI do

  use Maru.Router

  IO.puts "Setup routing"

  alias GnServer.Data.Store, as: Store
  alias GnServer.Logic.Assemble, as: Assemble

  @doc """
  Fetch all species in the database
  """

  get "/species" do
    # CSV version: text(conn,Enum.join(nlist,"\n"))
    json(conn, Store.species)
  end

  @doc """
  List all groups/crosses with ids
  """

  namespace :groups do
    route_param :species, type: String do
      get do
        json(conn, Store.groups(params[:species]))
      end
    end
  end


  @doc """
  Get the properties of a group/cross
  """

  namespace :group do
    route_param :name, type: String do
      get do
        [_,group] = Regex.run ~r/(.*)\.json$/, params[:name]
        json(conn, Assemble.group_info(group))
      end
    end
  end

  namespace :cross do
    route_param :name, type: String do
      get do
        [_,group] = Regex.run ~r/(.*)\.json$/, params[:name]
        json(conn, Assemble.group_info(group))
      end
    end
  end

  @doc """
  List all datasets with ids
  """

  namespace :datasets do
    route_param :dataset_name, type: String do
      get do
        json(conn, Store.datasets(params[:dataset_name]))
      end
    end
  end


  get do
    json(conn, %{"I am": :genenetwork})
  end

  get "/hey" do
    json(conn, %{"I am": :genenetwork})
  end

end
