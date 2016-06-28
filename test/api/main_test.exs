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

    assert Poison.decode!(value) ==
      %{"genetic_type" => "riset", "group" => "BXD", "group_id" => 1, "mapping_method_id" => 1, "species" => "mouse", "species_id" => 1, "chr_info" => [["1", 197195432], ["2", 181748087], ["3", 159599783], ["4", 155630120], ["5", 152537259], ["6", 149517037], ["7", 152524553], ["8", 131738871], ["9", 124076172], ["10", 129993255], ["11", 121843856], ["12", 121257530], ["13", 120284312], ["14", 125194864], ["15", 103494974], ["16", 98319150], ["17", 95272651], ["18", 90772031], ["19", 61342430], ["X", 166650296]]}
  end

  test "/group/1.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/group/1.json") |> make_response

    assert Poison.decode!(value) ==
      %{"genetic_type" => "riset", "group" => "BXD", "group_id" => 1, "mapping_method_id" => 1, "species" => "mouse", "species_id" => 1, "chr_info" => [["1", 197195432], ["2", 181748087], ["3", 159599783], ["4", 155630120], ["5", 152537259], ["6", 149517037], ["7", 152524553], ["8", 131738871], ["9", 124076172], ["10", 129993255], ["11", 121843856], ["12", 121257530], ["13", 120284312], ["14", 125194864], ["15", 103494974], ["16", 98319150], ["17", 95272651], ["18", 90772031], ["19", 61342430], ["X", 166650296]]}

  end


  test "/datasets/BXD" do
    %Plug.Conn{resp_body: value} = conn(:get, "/datasets/BXD") |> make_response
    assert Poison.decode!(value) == [[112, "HC_M2_0606_P", "Hippocampus Consortium M430v2 (Jun06) PDNN"]]
  end

  test "/dataset/'name'.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/dataset/HC_M2_0606_P.json") |> make_response

    assert Poison.decode!(value) ==
      %{"data_scale" => "log2", "full_name" => "Hippocampus Consortium M430v2 (Jun06) PDNN", "id" => 112, "name" => "HC_M2_0606_P", "public" => 2, "short_name" => "Hippocampus M430v2 BXD 06/06 PDNN", "tissue" => "Hippocampus mRNA", "confidential" => 0, "tissue_id" => 9}

  end

  test "/dataset/112.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/dataset/112.json") |> make_response
    assert Poison.decode!(value) ==
      %{"data_scale" => "log2", "full_name" => "Hippocampus Consortium M430v2 (Jun06) PDNN", "id" => 112, "name" => "HC_M2_0606_P", "public" => 2, "short_name" => "Hippocampus M430v2 BXD 06/06 PDNN", "tissue" => "Hippocampus mRNA", "confidential" => 0, "tissue_id" => 9}
  end

  test "/phenotypes/HC_M2_0606_P.json?start=100&stop=101" do
    %Plug.Conn{resp_body: value} = conn(:get, "/phenotypes/HC_M2_0606_P.json?start=100&stop=101") |> make_response
    assert Poison.decode!(value) ==
      [%{"MAX_LRS" => 30.4944361132252, "Mb" => 12.6694, "chr" => 12, "mean" => 7.232, "name" => "1452452_at", "name_id" => 1452452, "p_value" => 6.09756097560421e-5, "symbol" => "null", "additive" => 0.392331541218638, "locus" => "gnf12.013.284"}, %{"MAX_LRS" => 14.306552750747, "Mb" => 13.611444, "chr" => 1, "mean" => 7.2949696969697, "name" => "1460151_at", "name_id" => 1460151, "p_value" => 0.138, "symbol" => "null", "additive" => -0.106276737967914, "locus" => "rs3655978"}]
  end

  test "/phenotypes/112.json?stop=0" do
    %Plug.Conn{resp_body: value} = conn(:get, "/phenotypes/112.json?stop=0") |> make_response
    assert Poison.decode!(value) ==
    [%{"symbol" => "null", "MAX_LRS" => 30.4944361132252, "Mb" => 12.6694, "chr" => 12, "mean" => 7.232, "name" => "1452452_at", "name_id" => 1452452, "p_value" => 6.09756097560421e-5, "additive" => 0.392331541218638, "locus" => "gnf12.013.284"}]
  end

  test "/genotype/mouse/marker/rs3693478.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/genotype/mouse/marker/rs3693478.json") |> make_response
    assert Poison.decode!(value) ==
    [%{"symbol" => "null", "MAX_LRS" => 30.4944361132252, "Mb" => 12.6694, "chr" => 12, "mean" => 7.232, "name" => "1452452_at", "name_id" => 1452452, "p_value" => 6.09756097560421e-5, "additive" => 0.392331541218638, "locus" => "gnf12.013.284"}]
  end

  # Should add a test here for non-public

end
