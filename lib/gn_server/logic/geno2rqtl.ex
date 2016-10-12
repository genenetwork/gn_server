defmodule GnServer.Logic.Geno2Rqtl do

  # returns path to rqtl control file, e.g.
  # transform_file("inpath/cross.geno") -> "outpath/cross.json"
  def transform_file(in_path, out_dir) do
    # TODO better errors
    unless File.exists? in_path do
      {:enoent}
    else
      prev_path = System.cwd
      script_path = "./extra/geno2rqtl.rb" |> Path.absname

      result_name = Path.rootname(in_path) |> Path.basename
      # result_path = Path.rootname(path) <> "_rqtl"
      # result_path = out_dir

      # File.mkdir(result_path)
      # File.cd(result_path)
      File.cd(out_dir)

      # System.cmd("ruby", [script_path, in_path])
      IO.puts "created file in " <> out_dir

      File.cd(prev_path)

      {:ok, result_name <> ".json"}
      # {:ok, Path.join(out_dir, result_name) <> ".json"}
    end
  end
end
