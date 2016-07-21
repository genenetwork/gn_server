defmodule GnServer.Biodalliance.SNPDensity do
  alias GnServer.Data.Store, as: Store

  def snp_counts(chr, start_mb, end_mb, step, strain_id1, strain_id2) do
    num_bins = round((end_mb - start_mb) / step)

    0..num_bins
    |> Enum.map(fn b -> start_mb + (b * step) end)
    |> Enum.map(fn b -> Store.snp_count(chr, b, step, strain_id1, strain_id2) end)
  end
end
