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

  test "int/menu/main", %{hello: state} do
    %Plug.Conn{resp_body: value} = conn(:get, "int/menu/main.json") |> make_response
    assert Poison.decode!(value) ==
      %{"species" => [[1,"mouse","Mouse"],[4,"human","Human"]],
        "types" => %{"human" => %{"HLC" => [["Liver mRNA"]]},
                     "mouse" => %{"BXD" => [["Hippocampus mRNA"]]}},
        "groups" => %{ "mouse" =>
                         [[1,"BXD","BXD"]],
                       "human" =>
                         [[34,"HLC","Liver: Normal Gene Expression with Genotypes (Merck)"]]}}
  end

end
