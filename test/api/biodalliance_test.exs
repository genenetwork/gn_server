defmodule BiodallianceTest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.API

  test "/snp/features/" do
    %Plug.Conn{resp_body: value} = conn(:get, "/snp/features/11?start=1&end=10000000")
    |> make_response

    features = Poison.decode!(value)
    |> Map.get("features")
    |> Enum.sort_by(fn f -> f["start"] end)

    expected_scores = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 9, 3, 0, 0, 2, 6, 3, 4, 4, 0, 1, 2, 0, 2, 3, 2, 1, 3, 2, 3, 1, 5, 2, 1, 2, 4, 1, 4, 9, 2, 4, 10, 2, 27, 35, 12, 6, 2, 1, 2, 0, 8, 3, 2, 6, 13, 4, 5, 3, 0, 6, 4, 1, 4, 1, 5, 1, 1, 1, 2, 1, 2, 1, 1, 4, 0, 1, 0, 2, 8, 8, 4, 2, 1, 1, 1, 6, 1, 3, 4, 4, 3, 1, 3, 2, 3, 1, 8, 5, 1, 4, 3, 0, 29, 7, 6, 2, 4, 16, 183, 112, 116, 166, 131, 2, 96, 71, 5, 2, 12, 5, 1, 10, 6, 78, 113, 50, 4, 8, 40, 151, 159, 111]

    assert expected_scores == Enum.map(features, fn f -> f["score"] end)
  end
end
