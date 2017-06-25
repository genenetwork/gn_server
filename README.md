# GnServer

GeneNetwork server (GnServer) serves data and functionality over a
network interface. GnServer can fetch and upload data via a REST
API. GnServer can execute remote commands.

GnServer is implemented in the highly parallel and robust
[Elixir](http://elixir-lang.org) programming language on top of the
Erlang VM.

The API documentation can be found [here](./doc/API.md)
Note: GnServer is a work in progress (YMMV).

## Install via GNU Guix

Elixir and packages should soon come with a general genenetwork2
install. For now use the checked out GN2 repositories and install
Elixir with

```sh
env GUIX_PACKAGE_PATH=../guix-bioinformatics/ ./pre-inst-env guix package -i elixir
```

After setting the
[GUIX locale](https://github.com/pjotrp/guix-notes/blob/master/INSTALL.org#set-locale) (to avoid UTF-8 errors) install with mix

```sh
export GUIX_LOCPATH=$HOME/.guix-profile/lib/locale
export LC_ALL=en_US.UTF-8
mix hex.info
mix deps.get
mix test
```

which will probably render a database error. After
[starting](https://github.com/pjotrp/genenetwork2/tree/master/doc#run-mysql-server)
the database use the credentials for your system, e.g.,
"mysql://gn2:mysql_password@localhost/db_webqtl_s"

```
mysql -p -u gn2
use db_webqtl_s;
show tables;
```

Should show the tables as listed on [GeneNetwork](http://genenetwork.org/webqtl/main.py?FormID=schemaShowPage).

To start the server

```
iex -S mix
```

and the following should get you a reply

```
curl http://localhost:8880/hey
{"I am":"genenetwork"}
```

## Configure the service

A configuration file can be passed in. By default it uses the
test database with

```
iex -S mix run -c ./config/config.exs
```

and

```
curl http://localhost:8880/hey
{"I am":"genenetwork"}
```

To change the configuration, copy the confix.exs file and pass it in
on the command line, e.g.

```
cp ./config/config.exs ~/my_config.exs
iex -S mix run -c ~/my_config.exs
```

## Testing

See [tests](./doc/tests.org).

## License

The source code is released under the Affero General Public License 3
(AGPLv3). See [LICENSE.txt](LICENSE.txt).

## More information

For more information visit http://www.genenetwork.org/

## Contact

IRC on #genenetwork on irc.freenode.net.

Code and primary web service managed by Dr. Robert W. Williams and the
University of Tennessee Health Science Center, Memphis TN, USA.
