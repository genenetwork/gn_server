defmodule SubmitTest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.Router.Submit

  setup_all do
    token = GnServer.Logic.Token.compute_token(["user","token_test_input"])
    IO.puts "Computed token" <> token
    path = Application.get_env(:gn_server, :upload_dir) |> Path.join(token)
    File.mkdir_p(path)
    IO.puts "Created " <> path
    {:ok, token: token}
  end

  test "/echo" do
    res = conn(:put, "/echo", %{"Hello world" => nil,
                                "message" => "my message"}
                                     ) |> make_response
    # IO.inspect(res)
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) ==
      # %{"body" => "Hello world", "command" => "echo", "params" => %{"message" => "my message"}}
      "Hello world"
  end

  test "/submit/phenotypes" do
    res = conn(:put, "/submit/phenotypes") |> make_response
    # resp_body: "{\"submit\":\"ok\"}", resp_cookies: %{},
    # resp_headers: [{"cache-control", "max-age=0, private, must-revalidate"},
    # script_name: [], secret_key_base: nil, state: :sent, status: 200}

    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == ["ok"]
    %Plug.Conn{status: status} = res
    assert status == 200
  end

  test "Submit control file with /submit/rqtl/control", %{token: token} do
    IO.puts "***** control"
    # This will throw a validation error later (FIXME)
    res = conn(:put, "/submit/rqtl/control",
      %{"data" => "Hello world XXX",
        "token" => token,
        "filename" => "helloworld.txt"}) |> make_response
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == ["ok", "helloworld.txt"]
    %Plug.Conn{status: status} = res
    assert status == 200
    filen = Application.get_env(:gn_server, :upload_dir)
         |> Path.join(token) |> Path.join("helloworld.txt")
    assert File.exists?(filen)

    { :ok, data } = File.read("./test/data/input/rqtl/iron.yaml")
    res = conn(:put, "/submit/rqtl/control",
      %{"data" => data,
        "token" => token,
        "filename" => "iron.yaml" }) |> make_response
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == ["ok","iron.yaml"]
    %Plug.Conn{status: status} = res
    assert status == 200
    filen2 = Application.get_env(:gn_server, :upload_dir)
         |> Path.join(token) |> Path.join("iron.yaml")
    assert File.exists?(filen2)

  end

  test "Submit control file with /submit/rqtl/geno", %{token: token} do
    IO.puts "***** geno"
    { :ok, data } = File.read("./test/data/input/rqtl/iron_geno.csv")
    res = conn(:put, "/submit/rqtl/control",
      %{"data" => data,
        "token" => token,
        "filename" => "iron_geno.csv" }) |> make_response
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == ["ok","iron_geno.csv"]
    %Plug.Conn{status: status} = res
    assert status == 200
    filen = Application.get_env(:gn_server, :upload_dir)
         |> Path.join(token) |> Path.join("iron_geno.csv")
    assert File.exists?(filen)

  end

end
