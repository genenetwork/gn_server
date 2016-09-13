# GnServer Architecture

## Introduction

GnServer's main task is to serve a REST API for
GeneNetwork. Essentially it uses the Elixir programming language and
Erlang VM to leverage the strengths of data transformation and highly
parallel processing in a convenient functional programming paradigm.

## Executing external commands

GnServer can execute external commands by using System.cmd locally, or
GnExec remotely (System.cmd arguably belongs in GnExec).

A system command returns a return value (retval=int) and logs from
stdout and stderr. In addition resulting data is returned.

The interface is the same as with GnExec. To prevent sending
unneccessary data over the network the call returns the first time
with the retval and a token. The token is actually a calculated Hash
value (over the inputs) and is used to retrieve (progress) status and
the rest of the data which is waiting in a TEMPDIR.

The caller can add what files to expose in addition to STDOUT. The
only futher setting is whether a user wants to combine STDOUT and
STDERR in STDOUT - usually the case when return data is not part of
STDOUT.

So the first call to a program looks like the following REST sequence. First
set up the program with a dataset:

    URL/program/dataset.json

This returns a JSON record with a value and a token. For example

    {"retval" => 0, "token" => "8412ab517c6ef9c2f8b6dae3ed2a60cc"}

Now the program is running and we can get status updates with

    URL/program/status/8412ab517c6ef9c2f8b6dae3ed2a60cc.json

which returns

    {"retval" => 145, "progress" => 40, "token" => "8412ab517c6ef9c2f8b6dae3ed2a60cc"}

which says that the program is at 40% progress. When complete it should look like

    {"retval" => 0, "progress" => 100, "token" => "8412ab517c6ef9c2f8b6dae3ed2a60cc"}

and retval should contain a UNIX error value. Now to fetch the return data do

    URL/program/output/8412ab517c6ef9c2f8b6dae3ed2a60cc/result.json

or in whatever format. In fact, there is now an output directory named

    /var/tmp/8412ab517c6ef9c2f8b6dae3ed2a60cc/

on the server which contains all output files, including a file named
STDOUT which can be fetched with

    URL/program/output/8412ab517c6ef9c2f8b6dae3ed2a60cc/STDOUT

other output files can also be fetched by appending the filename(s).

One of the advantages of using the Hash value is that when an output
directory already exists it does not have to be recomputed. Results
can be returned immediately. To force a recalculation we add a
parameter to the original command:

    URL/program/dataset.json?recompute=1
