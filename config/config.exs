# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# See the README.md for configuring a server using a different
# conf file.

use Mix.Config

# config :logger, level: :debug
config :logger, level: :warn # set the default log level

config :maru, GnServer.API,
  http: [port: 8880]

config :gn_server, ecto_repos: [GnServer.Repo]

config :gn_server, GnServer.Repo,
  adapter: Ecto.Adapters.MySQL,
  database: "db_webqtl_s",
  username: "gn2",
  password: "mysql_password",
  hostname: "localhost",
  pool_size: 20,
  loggers: [{Ecto.LogEntry, :log, [:debug]}]  # set the logger above to :debug to see this output

config :gn_server, GnExec,
  pylmm_command: "runlmm.py"

config :gn_server,
  version: String.strip(File.read!("VERSION")),
  # The static path is local to the source repo by default
  static_path_prefix: "./test/data/input",
  cache_dir: "/var/tmp/gn_server",
  upload_dir: "/var/tmp/gn_server_data"
