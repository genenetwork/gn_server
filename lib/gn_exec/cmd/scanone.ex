defmodule GnExec.Cmd.ScanOne do
  alias GnExec.Cmd

  # First draft at running scanone on the
  #
  # when using GUIX don't forget to install r-qtl and r and set
  #
  #   export R_LIBS_SITE="/home/wrk/.guix-profile/site-library/"
  #
  # A script will run with
  #
  #   R CMD BATCH try.R
  #
  # Rscript will pipe to STDOUT and set the error status

  def cmd(dataset) do
    rscript = """
      cat("* Setting up R/qtl scanone")
      library(qtl)
    """
    File.write!("try.R",rscript)
    {output, 0} = System.cmd "Rscript", ["try.R"]
    output
  end
end
