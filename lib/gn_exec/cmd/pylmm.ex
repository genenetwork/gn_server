defmodule GnExec.Cmd.PyLMM do
  alias GnExec.Cmd

  # First draft at running pylmm on GnServer - this functionality
  # will move to GnExec in the near future. pylmm

  def cmd(dataset) do
    token = "8412ab517c6ef9c2f8b6dae3ed2a60cc"
    cache_dir = Application.get_env(:gn_server, :cache_dir)
    path = cache_dir <> "/" <> token
    File.mkdir_p!(path)
    # output = :os.cmd '/home/wrk/izip/git/opensource/genenetwork/pylmm_gn2/bin/runlmm.py --help'
    {output, retval} = System.cmd "/home/wrk/izip/git/opensource/genenetwork/pylmm_gn2/bin/runlmm.py", ["--help"],
      into: File.stream!(path <> "/STDOUT"), stderr_to_stdout: true
    # IO.inspect([output,retval,token])
    {retval,token}
  end
end
