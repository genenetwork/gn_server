defmodule APITest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.API

  setup_all do
    {:ok, hello: Poison.encode!(%{"I am": :genenetwork})}
  end

  test "/hey",%{hello: state} do
    # IO.inspect state
    %Plug.Conn{resp_body: value} = conn(:get, "/hey") |> make_response
    assert state == value
  end

  test "/", %{hello: state} do
    %Plug.Conn{resp_body: value} = conn(:get, "/") |> make_response
    assert state == value
  end

  test "/species" do
    %Plug.Conn{resp_body: value} = conn(:get, "/species") |> make_response
    assert Poison.decode!(value) == [[1,"mouse","Mus musculus"],[4,"human","Homo sapiens"]]
  end

  test "/cross/'name'.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/cross/BXD.json") |> make_response

    assert Poison.decode!(value) == %{"genetic_type" => "riset",
                                      "group" => "BXD", "group_id" => 1,
                                      "mapping_method_id" => 1,
                                      "species" => "mouse", "species_id" => 1}
  end

end
