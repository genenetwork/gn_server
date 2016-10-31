defmodule APITest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.API

  setup_all do
    version = Application.get_env(:gn_server, :version)
    {:ok, hello: Poison.encode!(%{"version": version, "I am": :genenetwork})}
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
    res = Poison.decode!(value)
    # IO.puts(Enum.count(res))
    assert Enum.reverse(res) |> Enum.take(1) ==
      [[17439, "Ric", "Immune system, infectious disease: Rickettsiu tsutsugamushi susceptibility (strain Gilliam, ip 100 50% mouse infectious doses, two treatments) of both sexes at 6-12 weeks-of-age (ordinal scale 0 = resistant, 1=susceptible, also see BXH RI set), maps to Gbp6 gene, see PMID 21551061) [mortality]"]]
    assert Enum.take(res,3) ==
      [[112, "HC_M2_0606_P", "Hippocampus Consortium M430v2 (Jun06) PDNN"], [10001, "CBLWT2", "Central nervous system, morphology: Cerebellum weight [mg]"], [10002, "ADJCBLWT", "Central nervous system, morphology: Cerebellum weight after adjustment for covariance with brain size [mg]"]]
    assert(Enum.count(res)==3642)
  end

  test "/dataset/HC_M2_0606_P.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/dataset/HC_M2_0606_P.json") |> make_response
    assert Poison.decode!(value) ==
      %{"dataset" => "probeset", "data_scale" => "log2", "full_name" => "Hippocampus Consortium M430v2 (Jun06) PDNN", "id" => 112, "name" => "HC_M2_0606_P", "public" => 2, "short_name" => "Hippocampus M430v2 BXD 06/06 PDNN", "tissue" => "Hippocampus mRNA", "confidential" => 0, "tissue_id" => 9}

  end

  @tag :skip
  test "/dataset/Ric.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/dataset/Ric.json") |> make_response
    assert Poison.decode!(value) ==
      %{"data_scale" => "log2", "full_name" => "Hippocampus Consortium M430v2 (Jun06) PDNN", "id" => 112, "name" => "HC_M2_0606_P", "public" => 2, "short_name" => "Hippocampus M430v2 BXD 06/06 PDNN", "tissue" => "Hippocampus mRNA", "confidential" => 0, "tissue_id" => 9}

  end

  test "/dataset/112.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/dataset/112.json") |> make_response
    assert Poison.decode!(value) ==
      %{"dataset" => "probeset", "data_scale" => "log2", "full_name" => "Hippocampus Consortium M430v2 (Jun06) PDNN", "id" => 112, "name" => "HC_M2_0606_P", "public" => 2, "short_name" => "Hippocampus M430v2 BXD 06/06 PDNN", "tissue" => "Hippocampus mRNA", "confidential" => 0, "tissue_id" => 9}
  end

  test "/dataset/10001.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/dataset/10001.json") |> make_response
    assert Poison.decode!(value) ==
      %{"dataset" => "phenotype", "descr" => "Central nervous system, morphology: Cerebellum weight [mg]", "id" => 10001, "name" => "CBLWT2", "pmid" => 11438585, "title" => "Genetic control of the mouse cerebellum: identification of quantitative trait loci modulating size and architecture", "year" => "2001"}
  end

  test "/phenotypes/HC_M2_0606_P.json?start=100&stop=101" do
    %Plug.Conn{resp_body: value} = conn(:get, "/phenotypes/HC_M2_0606_P.json?start=100&stop=101") |> make_response
    assert Poison.decode!(value) ==
      [%{"MAX_LRS" => 30.4944361132252, "Mb" => 12.6694, "chr" => 12, "mean" => 7.232, "name" => "1452452_at", "name_id" => 1452452, "p_value" => 6.09756097560421e-5, "symbol" => nil, "additive" => 0.392331541218638, "locus" => "gnf12.013.284"}, %{"MAX_LRS" => 14.306552750747, "Mb" => 13.611444, "chr" => 1, "mean" => 7.2949696969697, "name" => "1460151_at", "name_id" => 1460151, "p_value" => 0.138, "symbol" => nil, "additive" => -0.106276737967914, "locus" => "rs3655978"}]
  end

  test "/phenotypes/112.json?stop=0" do
    %Plug.Conn{resp_body: value} = conn(:get, "/phenotypes/112.json?stop=0") |> make_response
    assert Poison.decode!(value) ==
    [%{"symbol" => nil, "MAX_LRS" => 30.4944361132252, "Mb" => 12.6694, "chr" => 12, "mean" => 7.232, "name" => "1452452_at", "name_id" => 1452452, "p_value" => 6.09756097560421e-5, "additive" => 0.392331541218638, "locus" => "gnf12.013.284"}]
  end

  @tag :skip
  test "/phenotypes/10001.json?stop=0" do
    %Plug.Conn{resp_body: value} = conn(:get, "/phenotypes/10001.json?stop=0") |> make_response
    assert Poison.decode!(value) ==
    [%{"symbol" => nil, "MAX_LRS" => 30.4944361132252, "Mb" => 12.6694, "chr" => 12, "mean" => 7.232, "name" => "1452452_at", "name_id" => 1452452, "p_value" => 6.09756097560421e-5, "additive" => 0.392331541218638, "locus" => "gnf12.013.284"}]
  end

  test "/trait/10001.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/trait/10001.json") |> make_response
    res = Poison.decode!(value)
    assert res |> Enum.take(5) ==
      [[4, "BXD1", 61.400001525878906, nil], [5, "BXD2", 49.0, nil], [6, "BXD5", 62.5, nil], [7, "BXD6", 53.099998474121094, nil], [8, "BXD8", 59.099998474121094, nil]]
    assert Enum.count(res) == 34
  end

  test "/trait/12000.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/trait/12000.json") |> make_response
    res = Poison.decode!(value)
    assert res |> Enum.take(5) ==
      [[4, "BXD1", 8578.8125, nil], [5, "BXD2", 2714.55712890625, nil], [7, "BXD6", 3287.87841796875, nil], [8, "BXD8", 2572.21875, nil], [9, "BXD9", 10972.421875, nil]]
    assert Enum.count(res) == 64
  end

  @tag :skip
  test "/trait/CBLDT2.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/trait/CBLDT2.json") |> make_response
    assert Poison.decode!(value) == []
  end

  @tag :skip
  test "/trait/10001.csv" do
    %Plug.Conn{resp_body: value} = conn(:get, "/trait/10001.csv") |> make_response
    assert Poison.decode!(value) == []
  end

  test "/trait/12968.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/trait/12968.json") |> make_response
    # allowed, no PMID, but old enough
    assert Poison.decode!(value) |> Enum.take(5) ==
       [[2, "C57BL/6J", 0.12999999523162842, nil], [3, "DBA/2J", 1.0, nil], [6, "BXD5", 1.0, nil], [9, "BXD9", 1.0, nil], [10, "BXD11", 1.0, nil]]
  end

  test "/trait/17469.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/trait/17469.json") |> make_response
    assert value == "Server error" # not allowed, recent dataset
  end

  test "/trait/HC_M2_0606_P/1443823_s_at.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/trait/HC_M2_0606_P/1443823_s_at.json") |> make_response
    # result = Poison.decode!(value)
    [result | tail] = Poison.decode!(value)
    assert result ==
      [1, "B6D2F1", 15.251, nil]

    assert(Enum.count(tail)+1==99)
  end

  @tag :skip
  test "/trait/112/1443823_s_at.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/trait/112/1443823_s_at.json") |> make_response
    # result = Poison.decode!(value)
    [result | tail] = Poison.decode!(value)
    assert result ==
      [1, "B6D2F1", 15.251, nil]

    assert(Enum.count(tail)+1==99)
  end

  test "/trait/HC_M2_0606_P/1443823_s_at.csv" do
    %Plug.Conn{resp_body: value}  = conn(:get, "/trait/HC_M2_0606_P/1443823_s_at.csv") |> make_response
    assert(String.slice(value,0..100) == "id,value\n1,15.251\n2,15.626\n3,14.716\n4,15.198\n5,14.918\n6,15.057\n7,15.232\n8,14.968\n9,14.87\n10,15.084\n11")
  end

  test "/trait/HC_M2_0606_P/BXD/1443823_s_at.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/trait/HC_M2_0606_P/BXD/1443823_s_at.json") |> make_response
    [result | tail] = Poison.decode!(value)
    assert result == [1, "B6D2F1", 15.251, nil]

    assert(Enum.count(tail)+1==71)
  end

  test "/genotype/mouse/BXD.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/genotype/mouse/BXD.json") |> make_response
    assert Poison.decode!(value) ==
     %{"crosstype" => "riself", "description" => "BXD", "geno_transposed" => true, "genotypes" => %{"B" => 1, "D" => 2, "H" => 3}, "genotypes_descr" => %{"heterozygous" => 3, "maternal" => 1, "paternal" => 2}, "na.strings" => ["U"], "x_chr" => "X", "geno" => "genotype/mouse/BXD/geno.csv", "gmap" => "genotype/mouse/BXD/gmap.csv"}
  end

  test "/genotype/mouse/BXD/geno.csv" do
    %Plug.Conn{resp_body: _, status: 200}  = conn(:get, "/genotype/mouse/BXD/geno.csv") |> make_response
  end

  test "/genotype/mouse/BXD/gmap.csv" do
    %Plug.Conn{resp_body: _, status: 200}  = conn(:get, "/genotype/mouse/BXD/gmap.csv") |> make_response
  end

  test "/genotype/mouse/marker/rs3693478.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/genotype/mouse/marker/rs3693478.json") |> make_response
    assert Poison.decode!(value) ==
     [%{"chr" => "7", "chr_len" => 67.179978, "marker" => "rs3693478", "source" => "Illumina_5530", "species" => "mouse", "species_id" => 1}]
  end

  test "HC_M2_0606_P, public 2, confidentiality 0" do
    # we know this works already from above
  end

  test "EPFL-LISP_MusPMetHFD1213, public 1, confidentiality 1" do
    %Plug.Conn{resp_body: value} = conn(:get, "/dataset/EPFL-LISP_MusPMetHFD1213.json") |> make_response
    assert value == "Server error"
  end

  # HC_M2_1205_R, public 0, confidentiality 0
  # EPFLBXDprot0513, public 0, confidentiality 1

  test "/static/test" do
    %Plug.Conn{resp_body: value} = conn(:get, "/static/test") |> make_response
    assert value == "test\n"
  end

  @tag :skip
  test "/qtl/scanone/iron.json" do
    # Note, to have this test pass you have to install R/qtl
    %Plug.Conn{resp_body: value} = conn(:get, "/qtl/scanone/iron.json") |> make_response
    assert Poison.decode!(value) == "* Setting up R/qtl scanone"
  end

  test "/qtl/pylmm/iron.json" do
    %Plug.Conn{resp_body: value} = conn(:get, "/qtl/pylmm/iron.json") |> make_response
    # IO.puts(value)
    assert Poison.decode!(value) ==
      %{"retval" => 0, "token" => "8412ab517c6ef9c2f8b6dae3ed2a60cc"}
  end
end
