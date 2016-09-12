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
value (over the inputs) and is used to retrieve the rest of the data
which is waiting in a TEMPDIR.

The caller can add what files to expose in addition to STDOUT. The
only futher setting is whether a user wants to combine STDOUT and
STDERR in STDOUT - usually the case when return data is not part of
STDOUT.
