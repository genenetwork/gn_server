# GnServer

GeneNetwork server (GnServer) serves data and functionality over a
network interface. GnServer can fetch and upload data over a REST
interface. GnServer can execute remote commands.

GnServer is implemented in the highly parallel and robust Elixir
programming language on top of the Erlang VM.

Note: GnServer is a work in progress (YMMV).

## GNU Guix installation

Elixir and packages should come soon with a general genenetwork2
install. For now use the checked out GN2 repositories and install
Elixir with

```sh
env GUIX_PACKAGE_PATH=../guix-bioinformatics/ ./pre-inst-env guix package -i elixir
```

After setting the
[GUIX locale](https://github.com/pjotrp/guix-notes/blob/master/INSTALL.org#set-locale) (to avoid UTF-8 errors) install with mix

```sh
mix hex.info
mix run
```
    
## Source code installation

If [available in Hex](https://hex.pm/docs/publish), the package can be
installed by providing:

  1. Add gn_server to your list of dependencies in `mix.exs`:

        def deps do
          [{:gn_server, "~> 0.0.1"}]
        end

  2. Ensure gn_server is started before your application:

        def application do
          [applications: [:gn_server]]
        end

