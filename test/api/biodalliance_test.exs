defmodule BiodallianceTest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.API

  test "/snp/features/" do
    %Plug.Conn{resp_body: value} = conn(:get, "/snp/features/11?start=3000000&end=3200000")
    |> make_response

    features = Poison.decode!(value)
    |> Map.get("features")
    |> Enum.sort_by(fn f -> f["start"] end)

    expected_scores = [14, 3, 1]

    assert expected_scores == Enum.map(features, fn f -> f["score"] end)
  end
end
