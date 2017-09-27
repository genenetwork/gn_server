defmodule InternalAPITest do
  # use Maru.Router, make_plug: true
  use ExUnit.Case, async: true
  use Maru.Test # , root: GnServer.Biodalliance.SNPDensity


  setup_all do
    {:ok, hello: Poison.encode!(%{"I am": :genenetwork, api: :internal})}
  end

  test "int/", %{hello: state} do
    value = get("int/") |> text_response
    assert state == value
  end

  test "int/menu/main" do
    %Plug.Conn{resp_body: value} = get("int/menu/main.json") |> text_response
    assert Poison.decode!(value) ==
      %{
        "datasets" => %{"human" => %{"HLC" => %{"Liver mRNA" => [[320,
                           "HLC_0311",
                           "GSE9588 Human Liver Normal (Mar11) Both Sexes"]]}},
                        "mouse" => %{"BXD" => %{"Hippocampus mRNA" => [[112,
                            "HC_M2_0606_P",
                            "Hippocampus Consortium M430v2 (Jun06) PDNN"]]}}},
             "groups" => %{"human" => [[34, "HLC",
                 "Liver: Normal Gene Expression with Genotypes (Merck)"]],
               "mouse" => [[1, "BXD", "BXD"]]},
             "menu" => %{"human" => %{"menu" => "Human",
                 "types" => %{"HLC" => [["Liver mRNA"]]}},
               "mouse" => %{"menu" => "Mouse",
                 "types" => %{"BXD" => [["Hippocampus mRNA"]]}}}}
  end

end
