# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# See the README.md for configuring a server using a different
# conf file.

use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :gn_server, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:gn_server, :key)
#
# Or configure a 3rd-party app:
#
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

# config :logger, level: :debug
config :logger, level: :warn

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
  loggers: [{Ecto.LogEntry, :log, [:debug]}]  # run with MIX_ENV=prod to drop SQL output

config :gn_server, GnExec,
  pylmm_command: "runlmm.py"

config :gn_server,
  version: String.strip(File.read!("VERSION")),
  # The static path is local to the source repo by default
  static_path_prefix: "./test/data/input",
  cache_dir: "/var/tmp/gn_server",
  upload_dir: "/var/tmp/gn_server_data"
