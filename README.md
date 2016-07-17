# GnServer

GeneNetwork server (GnServer) serves data and functionality over a
network interface. GnServer can fetch and upload data via a REST
API. GnServer can execute remote commands.

GnServer is implemented in the highly parallel and robust Elixir
programming language on top of the Erlang VM.

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

which will probably render a database error. To start the database use
the credentials for your system, e.g.,
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

## Install via Hex

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

## Configure the service

A configuration file can be passed in. By default it uses the
test database with

```
iex -S mix -- ./etc/test_settings.json
```

and

```
curl http://localhost:8880/hey
{"I am":"genenetwork"}
```

## Benchmarking

brew install sysbench
 Create user sbstest with dba grants from the workbench
 Create a sbtest database from the workbench
sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=sbtest --mysql-user=sbtest --mysql-password=sbtest --mysql-table-engine=myisam prepare
sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=sbtest --mysql-user=sbtest --mysql-password=sbtest --max-time=60 --oltp-read-only=on --max-requests=0 --num-threads=4 --mysql-table-engine=myisam run

sysbench 0.4.12:  multi-threaded system evaluation benchmark

No DB drivers specified, using mysql
Running the test with following options:
Number of threads: 4

    Doing OLTP test.
    Running mixed OLTP test
    Doing read-only test
    Using Special distribution (12 iterations,  1 pct of values are returned in 75 pct cases)
    Using "LOCK TABLES READ" for starting transactions
    Using auto_inc on the id column
    Threads started!
    Time limit exceeded, exiting...
    (last message repeated 3 times)
    Done.

    OLTP test statistics:
        queries performed:
            read:                            916370
            write:                           0
            other:                           130910
            total:                           1047280
        transactions:                        65455  (1090.91 per sec.)
        deadlocks:                           0      (0.00 per sec.)
        read/write requests:                 916370 (15272.74 per sec.)
        other operations:                    130910 (2181.82 per sec.)

    Test execution summary:
        total time:                          60.0004s
        total number of events:              65455
        total time taken by event execution: 239.5199
        per-request statistics:
             min:                                  1.74ms
             avg:                                  3.66ms
             max:                                145.89ms
             approx.  95 percentile:               5.07ms

    Threads fairness:
        events (avg/stddev):           16363.7500/85.88
        execution time (avg/stddev):   59.8800/0.00

## License

The source code is released under the Affero General Public License 3
(AGPLv3). See [LICENSE.txt](LICENSE.txt).

## More information

For more information visit http://www.genenetwork.org/

## Contact

IRC on #genenetwork on irc.freenode.net.

Code and primary web service managed by Dr. Robert W. Williams and the
University of Tennessee Health Science Center, Memphis TN, USA.
