
defmodule GnServer.Biodalliance.Control do
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


defmodule GnServer.Biodalliance.Tracks do
  @moduledoc """
  Keeps track of all R/QTL2 tracks, and manages fetching of data
  and serving it to the router

  Should be able to serve data both from files as well as databases
  """

  use GenServer

  def start_link do
    Agent.start_link(fn -> %{} end, name: :rqtl_tracks)
  end

  def add_track(track_name, file) do
    ctrl = GnServer.Biodalliance.Control.parse_control(file)
    Agent.update(:rqtl_tracks, fn tracks -> Map.put(tracks, track_name, ctrl) end)
  end

  def get_control(track_name) do
    Agent.get(:rqtl_tracks, fn tracks -> tracks[track_name] end)
  end

  def get_file(track_name, file) do
    filename = Agent.get(:rqtl_tracks, fn tracks ->
      tracks[track_name][file]
    end)
    File.read(filename)
  end

end
