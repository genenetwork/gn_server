
defmodule GnServer.Rqtl.Control do
  defstruct crosstype: "", geno: "", pheno: "", phenocovar: "",
    covar: "", gmap: "", alleles: [], genotypes: {}, sex: {},
    cross_info: {}, x_chr: "", na_strings: []


  @doc """
  Parses a JSON-formatted R/QTL2 control file.
  """
  def parse_control(path) do
    {:ok, file} = File.read(path)
    # {:ok, obj} = Poison.decode(file, as: %GnServer.Rqtl.Control{})
    {:ok, obj} = Poison.decode(file)
    obj
  end

  @doc """
  Adds an URI root to a parsed control object
  """
  def add_uri_root(ctrl, root) do
    %GnServer.Rqtl.Control{ ctrl | geno: root <> ctrl.geno,
                            pheno: root <> ctrl.pheno, phenocovar: root <> ctrl.phenocovar,
                            covar: root <> ctrl.covar, gmap: root <> ctrl.gmap }
  end
end


defmodule GnServer.Rqtl.Tracks do
  @moduledoc """
  Keeps track of all R/QTL2 tracks, and manages fetching of data
  and serving it to the router

  Should be able to serve data both from files as well as databases
  """

  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      # serve genotype, gmap, etc. file
      {:get_file, {track_name, file}, caller} ->
        ctrl = Map.get(map, track_name)
        case Map.get(map, track_name) do
          nil  ->
            send caller, {:error, "Track doesn't exist"}
          ctrl ->
            {:ok, content} = File.read(ctrl[file])
            send caller, content
        end
        loop(map)

      ## Add a track, given a control file path
      {:add_track, {track_name, file}, caller} ->
        ctrl =
          GnServer.Rqtl.Control.parse_control(file)
          # |> GnServer.Rqtl.Control.add_uri_root("./")
        send caller, {:ok, "Track added"}
        loop(Map.put(map, track_name, ctrl))

      # get track control file (mostly for testing and debugging)
      {:get_control, track_name, caller} ->
        case Map.get(map, track_name) do
          nil  ->
            send caller, {:error, "Track doesn't exist"}
          ctrl ->
            send caller, ctrl
        end
        loop(map)
    end
  end
end
