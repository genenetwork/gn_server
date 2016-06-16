defmodule InternalAPITest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.API

  setup_all do
    {:ok, hello: Poison.encode!(%{"I am": :genenetwork, api: :internal})}
  end

  test "int/", %{hello: state} do
    %Plug.Conn{resp_body: value} = conn(:get, "int/") |> make_response
    assert state == value
  end

  test "int/menu/main" do
    %Plug.Conn{resp_body: value} = conn(:get, "int/menu/main.json") |> make_response
    assert Poison.decode!(value) ==
      %{"datasets" => %{"human" => %{"HLC" => %{"Liver mRNA" => [[320,
                     "HLC_0311",
                     "GSE9588 Human Liver Normal (Mar11) Both Sexes"]]}},
               "mouse" => %{"BXD" => %{"Hippocampus mRNA" => [[112,
                     "HC_M2_0606_P",
                     "Hippocampus Consortium M430v2 (Jun06) PDNN"]]}}},
             "groups" => %{"human" => [[34, "HLC",
                 "Liver: Normal Gene Expression with Genotypes (Merck)"]],
               "mouse" => [[1, "BXD", "BXD"]]},
             "species" => [[1, "mouse", "Mouse"], [4, "human", "Human"]],
             "types" => %{"human" => %{"HLC" => [["Liver mRNA"]]},
               "mouse" => %{"BXD" => [["Hippocampus mRNA"]]}}}

  end

end
