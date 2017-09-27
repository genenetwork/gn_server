defmodule SubmitTest do
  use ExUnit.Case, async: true
  use Maru.Test

  setup_all do
    token = GnServer.Logic.Token.compute_token(["user","token_test_input"])
    IO.puts "Computed token" <> token
    path = Application.get_env(:gn_server, :upload_dir) |> Path.join(token)
    File.mkdir_p(path)
    IO.puts "Mkdir " <> path
    {:ok, token: token}
  end

  defp upload_rqtl_file token, _filetype, uploadfn do
    { :ok, data } = File.read("./test/data/input/rqtl/#{uploadfn}")
    res = put("/submit/rqtl/control",
      %{"data" => data,
        "token" => token,
        "filename" => uploadfn }) |> text_response
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == ["ok", uploadfn]
    %Plug.Conn{status: status} = res
    assert status == 200
    filen = Application.get_env(:gn_server, :upload_dir)
         |> Path.join(token) |> Path.join(uploadfn)
    assert File.exists?(filen)
  end

  test "/echo" do
    res = put("/echo", %{"Hello world" => nil,
                                "message" => "my message"}
                                     ) |> text_response
    # IO.inspect(res)
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) ==
      # %{"body" => "Hello world", "command" => "echo", "params" => %{"message" => "my message"}}
      "Hello world"
  end

  test "/submit/phenotypes" do
    res = put("/submit/phenotypes") |> text_response
    # resp_body: "{\"submit\":\"ok\"}", resp_cookies: %{},
    # resp_headers: [{"cache-control", "max-age=0, private, must-revalidate"},
    # script_name: [], secret_key_base: nil, state: :sent, status: 200}

    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == ["ok"]
    %Plug.Conn{status: status} = res
    assert status == 200
  end

  test "Submit control file with /submit/rqtl/control", %{token: token} do
    # This non-YAML should throw a validation error later (FIXME)
    res = put("/submit/rqtl/control",
      %{"data" => "Hello world XXX",
        "token" => token,
        "filename" => "helloworld.txt"}) |> text_response
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == ["ok", "helloworld.txt"]
    %Plug.Conn{status: status} = res
    assert status == 200
    filen = Application.get_env(:gn_server, :upload_dir)
         |> Path.join(token) |> Path.join("helloworld.txt")
    assert File.exists?(filen)

    upload_rqtl_file token, "control", "iron.yaml"
  end

  test "Submit file with /submit/rqtl/geno", %{token: token} do
    upload_rqtl_file token, "geno", "iron_geno.csv"
  end

  test "Submit file with /submit/rqtl/pheno", %{token: token} do
    upload_rqtl_file token, "pheno", "iron_pheno.csv"
  end

  test "Submit file with /submit/rqtl/gmap", %{token: token} do
    upload_rqtl_file token, "gmap", "iron_gmap.csv"
  end

  test "Submit file with /submit/rqtl/covar", %{token: token} do
    upload_rqtl_file token, "covar", "iron_covar.csv"
  end

end
