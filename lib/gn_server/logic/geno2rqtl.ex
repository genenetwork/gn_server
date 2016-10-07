defmodule GnServer.Logic.Geno2Rqtl do

  # returns path to rqtl control file, e.g.
  # transform_file("inpath/cross.geno") -> "outpath/cross.json"
  def transform_file(path) do
    prev_path = System.cwd
    script_path = "./extra/geno2rqtl.rb" |> Path.absname

    result_name = Path.rootname(path) |> Path.basename
    result_path = Path.rootname(path) <> "_rqtl"

    File.mkdir(result_path)
    File.cd(result_path)

    System.cmd("ruby", [script_path, path])

    File.cd(prev_path)

    Path.join(result_path, result_name) <> ".json"
  end
end
