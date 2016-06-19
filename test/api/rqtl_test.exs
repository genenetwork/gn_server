defmodule BiodallianceTest do
  use ExUnit.Case

  setup do
     file = GnServer.Biodalliance.Control.parse_control("./test/data/input/genotype/iron.json")
     {:ok, ctrl: file}
  end

  test "Test parsing R/QTL control file", state  do
    keys = ["crosstype", "geno", "pheno", "phenocovar",
            "covar", "gmap", "alleles", "genotypes", "sex",
            "cross_info", "x_chr", "na.strings"]
    Enum.map(keys, fn(x) -> # IO.puts x; 
      assert Map.has_key?(state[:ctrl], x) end)
  end

end
