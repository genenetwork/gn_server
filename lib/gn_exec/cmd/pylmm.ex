defmodule GnExec.Cmd.PyLMM do
  alias GnExec.Cmd

  # First draft at running scanone on GnServer - this functionality
  # will move to GnExec in the near future

  def cmd(dataset) do
    # File.write!("try.R",rscript)
    {output, 0} = System.cmd "/home/wrk/izip/git/opensource/genenetwork/pylmm_gn2/bin/runlmm.py", ["--help"]
    output
  end
end
