defmodule GnExec.Cmd.Echo do
  alias GnExec.Cmd

  # First draft at running 'echo' on GnServer - this functionality
  # will move to GnExec in the near future
  #

  def cmd(s) do
    {output, 0} = System.cmd "/bin/echo", [s]
    output
  end
end
