
defmodule GnServer do
  use Application

  def testdir(dirname) do
    dir = Application.get_env(:gn_server, dirname)
    File.mkdir_p(dir)
    if !File.dir?(dir) do
      raise "config #{dirname} does not exist: " <> dir
    end
  end


  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    testdir :cache_dir
    testdir :upload_dir

    children = [
      # Start the endpoint when the application starts
      supervisor(GnServer.Repo, []),
      # Start the Ecto repository
      #worker(GnServer.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(PhoenixMaru.Worker, [arg1, arg2, arg3]),
      worker(Cachex, [:gn_server_cache, [ default_ttl: :timer.minutes(10*3600)]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GnServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  # def config_change(changed, _new, removed) do
  #   PhoenixMaru.Endpoint.config_change(changed, removed)
  #   :ok
  # end
end
