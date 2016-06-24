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

  test "/groups/mouse" do
    %Plug.Conn{resp_body: value} = conn(:get, "/groups/mouse") |> make_response
    assert Poison.decode!(value) == [[1,"BXD","BXD"]]
  end

  test "/groups/1" do
    %Plug.Conn{resp_body: value} = conn(:get, "/groups/1") |> make_response
    assert Poison.decode!(value) == [[1,"BXD","BXD"]]
  end

  test "/group/'name'.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/group/BXD.json") |> make_response

    assert Poison.decode!(value) == %{"genetic_type" => "riset",
                                      "group" => "BXD", "group_id" => 1,
                                      "mapping_method_id" => 1,
                                      "species" => "mouse", "species_id" => 1}
  end

  test "/group/1.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/group/1.json") |> make_response

    assert Poison.decode!(value) == %{"genetic_type" => "riset",
                                      "group" => "BXD", "group_id" => 1,
                                      "mapping_method_id" => 1,
                                      "species" => "mouse", "species_id" => 1}
  end


  test "/datasets/BXD" do
    %Plug.Conn{resp_body: value} = conn(:get, "/datasets/BXD") |> make_response
    assert Poison.decode!(value) == [[1,"mouse","Mus musculus"],[4,"human","Homo sapiens"]]
  end

  test "/dataset/'name'.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/dataset/HC_M2_0606_P.json") |> make_response

    assert Poison.decode!(value) == %{
                                      "group" => "BXD", "group_id" => 1,
                                      "species" => "mouse", "species_id" => 1}
  end

end
