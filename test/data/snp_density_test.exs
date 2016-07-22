defmodule SNPDensityTest do
  use ExUnit.Case
  alias GnServer.Data.Store, as: Store
  alias GnServer.Biodalliance.SNPDensity, as: SNPDensity

  test "SNP density count" do
    count = Store.snp_count(1, 0, 1, 2, 3)
    assert count == 55
  end

  test "SNP density over chromosome" do
    result = SNPDensity.snp_counts(1, 2, 10, 2, 2, 3)

    expected_starts = 1..5 |> Enum.map(fn x -> x * 2.0 end)
    expected_ends = expected_starts |> Enum.map(fn x -> x + 2.0 end)
    expected_scores = [3006, 3924, 2950, 3578, 1875]

    assert expected_scores == Enum.map(result, fn c -> c.score end)
    assert expected_starts == Enum.map(result, fn c -> c.start end)
    assert expected_ends == Enum.map(result, fn c -> c.end end)
  end
end
