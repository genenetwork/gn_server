# GnServer Architecture

## Introduction

GnServer's main task is to serve a REST API for GeneNetwork. REST can
be used by any modern computer language to access remote data and
services. On the backend it uses the Elixir programming language and
Erlang VM to leverage the strengths of data transformation and highly
parallel processing in a convenient functional programming paradigm.

## REST API

The rest (test) API to fetch data is described in [API.md](API.md).

## REST server program execution

Here we describe how we implement running a monitored service and make
it available through the REST API.

### Upload data

The first step is to upload data that can be processed as input
file(s).  In this example we'll upload a phenotype file. For this we
first ask for an area to upload and that is done through a unique hash
value.

    curl -X POST -d username="Rob Williams" -d tokenid=projectid http://127.0.0.1:8880/token/get
    CeaRwqNSkrlO7fMPpVa4Yle1dRJxkHjFddrHhotJkxg

the returned token also represents a physical disk directory and the
name can be regenerated using the same input tokenid and user
combination. It is storage that is persistent - though it may expire
at some point if the storage is not registered to be fully persistent
(see below). Typically one token will be used for one analysis. That
is why you can specify a projectid.

The next step is to upload data. Upload some files in R/qtl2
format from http://kbroman.org/qtl2/pages/sampledata.html using
the token

```sh
    wget http://kbroman.org/qtl2/assets/sampledata/iron/iron.yaml
    cat iron.yaml |curl -X PUT -d @- -d filename="iron.yaml" -d token="CeaRwqNSkrlO7fMPpVa4Yle1dRJxkHjFddrHhotJkxg=" http://127.0.0.1:8880/submit/rqtl/control
    {:ok => :submitted}
```

Note that once a file has been submitted it becomes immutable. You
can't remove or overwrite a single file on the server. If you want to
use the same names use a new projectid and create a new token. You
can, however, remove a project by its token:

: curl -X POST -d username="Rob Williams" -d tokenid=projectid http://127.0.0.1:8880/token/remove/CeaRwqNSkrlO7fMPpVa4Yle1dRJxkHjFddrHhotJkxg=

```sh

### Fully persistent storage

### Run program

What we want to achieve is running a program through the REST interface with
something like

    curl http://127.0.0.1:8880/echo/hello

which should return "hello".

The simple way to run a program in Elixir is something like

```elixir
  def cmd(s) do
    {output, 0} = System.cmd "/bin/echo", [s]
    output
  end
```

which handles errors, but can't show progress, nor can running
processes easily be interrupted. But this we'll do later.

### Serve result

There are two routes to serve a result.

### Progress meter

### Interrupt running process

## WARNING ==== The following text is being updated ====

Below text was written up in a previous incarnation and needs to be
checked/updated.

## Executing external commands

By design GnServer can execute external commands by using System.cmd
locally, or GnExec remotely (System.cmd arguably belongs in GnExec and local
commands will disappear over time).

A system command returns a return value (`retval=int`) and logs from
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

    URL/program/8412ab517c6ef9c2f8b6dae3ed2a60cc/status.json

which returns

    {"retval" => 145, "progress" => 40, "token" => "8412ab517c6ef9c2f8b6dae3ed2a60cc"}

which says that the program is at 40% progress. When complete it should look like

    {"retval" => 0, "progress" => 100, "token" => "8412ab517c6ef9c2f8b6dae3ed2a60cc"}

and now retval should contain a UNIX error value (retval 144=queued,
145=running, 146=killed, all other non zero values are errors).

After completion, to fetch the return data do

    URL/program/output/8412ab517c6ef9c2f8b6dae3ed2a60cc/result.json

or in whatever format. In fact, there is now an output directory named

    /var/tmp/8412ab517c6ef9c2f8b6dae3ed2a60cc/

on the server which contains all output files, including a file named
STDOUT (optionally STDERR) which can be fetched with

    URL/program/output/8412ab517c6ef9c2f8b6dae3ed2a60cc/STDOUT

even when the job errored out.  Other output files can also be fetched
by appending the filename(s).

One of the advantages of using the Hash value is that when an output
directory already exists it does not have to be recomputed. Results
can be returned immediately. To force a recalculation (say on error)
we add a parameter to the original command:

    URL/program/dataset.json?force_recompute=1

or

    URL/program/dataset.json?recompute_on_error=1

Another option is to kill a running job with

    URL/program/8412ab517c6ef9c2f8b6dae3ed2a60cc/status.json?kill=1

should return

    {"retval" => 146, "token" => "8412ab517c6ef9c2f8b6dae3ed2a60cc"}

A mechanism is in place to prevent two of the same jobs running on the
same system. Once a job is running it is automatically shared between
the two 'users'.

## TechPlan

GnServer will leverage GnExec in many ways.

### Todo

#### Docs

- [ ] search for a formal definition of *Opportunistic Computing* or papers
- [ ] detailed dev plan
- [ ] deploy guide
- [ ] developers tutorial

#### GnServer

- [x] Receive a file associated with a job and store it locally, gn_exec transfer files after the computation.
- [ ] Client can request list of supported software
- [ ] write tests
- [ ] How jobs are retained on the gn_server side ? Local actor that keeps a very simple queue?
- [ ] kill job
- [ ] force recompute
- [ ] recompute_on_error
- [ ] check that transferred files have the correct checksum

#### GnExec

- [ ] Create a local directory with the name of the hash/job
- [ ] loop request/jobs
- [ ] Support PBS, submit jobs (qsub) and monitor (qstat)
- [ ] defined and document hooks/callbacks for job/loop aka how to deal with output or job events.
- [ ] how to manage resources ? With PBS, the management of the resources is delegated to it, locally concurrent jobs are not yet supported.
- [ ] update stdout on gn_server every time the stdout is update on GnExec client
- [x] UPLOAD FILES, send file(s) over http when job is over, file by file.
- [ ] UPLOAD FILES, check that all the subdirectories are transferred



### GnExec Overview

Excute GnServer jobs on remote hosts following an opportunistic or [disperse
computing](http://www.darpa.mil/program/dispersed-computing) approach.

Delegate job execution to volunteer computing


GnExec is an ensemble solution

  1. Local store for jobs
  2. Execute locally stored jobs
  3. GnServer REST API client

GnExec use only Elixir and Erlang libraries and tools. The local store will be based on Mnesia.


### General Overview

- Dispatch jobs upon client request.
- Collect results and metrics from clients.
- Aggegate metric to learn how better distribute the jobs to clients.
- Distribute the same job multiple times, collect the first computed result.
- Upon client/job resul, wait interaction from other client with the
  same/similar job and instruct them to continue or terminate their computation.
- Test system, server will provide test data for each required computation
  to perform metrics and verify the ability of the client to satisfy server requests.
- Client declares its available resources, the Central Dipatch Unit (CDU) try to
  match and predict the *optimal* parameters if availabe and estimate the computing time
  to provide a feedback to the end user.
- Metrics:
  - *To Be Defined (TBD)*


### Why REST?

Builing an interoperable decentralized computing infrastructure is a challenging task.

REST will let us develop clients that satisfty specific requirements in terms
of security, infrastructure, platform and OS.

Solid building blocks, Elixir for its semplicity to create reliable services based
on Erlang capabilities dealing with fault tolerance and distributed systems.


### Volunteers

We defined volunteers any client that consumes the GnExec REST API.
Our primary target is to leverage by [GnServer](https://github.com/genenetwork/gn_server)
the computing power of the [BEACON](https://www.nics.tennessee.edu/beacon) at
University of Tennessee in a secure way.

### References

- Disperse Computing http://www.darpa.mil/program/dispersed-computing
- A Language for Distributed, Eventually Consistent Computations https://lasp-lang.org/
- Elixir Language http://elixir-lang.org/

### Workflow

The system is designed to be stateless, or to minimize the amount of information saved on the server side.
API are versioned to improve functionalities over time. Version 0.1 will be very simple with a limited number of controls and security checks.

Server and client will communicate over REST, websocket could be used in the future for better control if needed.

List of possible improvements

* client provides information about its computing capabilities
* server dispatch to certain client specific jobs
* server store statistics about clients
* manage clients account
* transferring huge files
* describe the required environment to execute the computation.
    - cpu
    - ram
    - disk
    - software capabilities
    - software environment


### API

Commands must define a `script` function that returns the commands executed by the remote environment, usually `bash`. The number of parameters for the `script` is not fixed and the function is called by the system in a dynamic way, so that developers can implement their own script function.

    def script(directory, parameters \\ '') do
      """

    echo "This is a test string written to a file on the current working directory" > echo_test.txt
    ls #{parameters} #{directory}
    sleep 10
    ls #{parameters} #{directory}
    touch send_file_created.txt

    """
    end

All files generated by the script command in the current working directory are later transferred to gn_server.

#### Tutorial

Client can not list available jobs for to reduce the risk of inspecting workload or server activities.

The client request a new job providing the name of the program and some parameter

    GnExec.Rest.Job.get("program",["data"])

program must be a valid GnExec supported software.

the client hits the server on

    URL/gnexec/program/dataset.json

Similar to

    curl -i -H "Accept: application/json" http://127.0.0.1:8880/gnexec/Ls/dataset.json

The server creates a `GnExec.Rest.job` and returns it to the client

    job = GnExec.Rest.Job.new(program,[data])

the client now runs the job

    GnExec.Rest.Job.run(GnExec.Rest.Job.get("program",["data"]))

On the gn_exec machine the system creates a local directory with the token name and run the job in a spawned task setting the working directory to the name of the token. After the completion of the of the job all the files inside the working directory are transferred to the remote gn_server.


Get job status

    curl -i -H "Accept: application/json" http://127.0.0.1:8880/program/b2bc54b2a885d6fa61e1e86b22a837445a5abc8722331be6410d019ef0c49d45/status.json

Update status

    curl -i -H "Accept: application/json" -X PUT -d progress=52 http://127.0.0.1:8880/program/b2bc54b2a885d6fa61e1e86b22a837445a5abc8722331be6410d019ef0c49d45/status.json

Transfer a file to the server

    curl --form "file=@LOCAL FILE NAME" -i -H "Accept: application/json" http://127.0.0.1:8880/gnexec/program/b2bc54b2a885d6fa61e1e86b22a837445a5abc8722331be6410d019ef0c49d45
