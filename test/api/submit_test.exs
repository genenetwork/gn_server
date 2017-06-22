defmodule SubmitTest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.Router.Submit

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

  test "Submit control file with /submit/rqtl/control" do
    token = GnServer.Logic.Token.compute_token(["user","token_test_input"])
    IO.puts "Computed token" <> token

    path = Application.get_env(:gn_server, :upload_dir)
    |> Path.join(token)

    File.mkdir_p(path)
    res = conn(:put, "/submit/rqtl/control",
      %{"Hello world XXX" => nil,
        "token" => token,
        "filename" => "helloworld.txt"}) |> make_response
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == ["ok"]
    %Plug.Conn{status: status} = res
    assert status == 200
    filen = Application.get_env(:gn_server, :upload_dir)
         |> Path.join(token) |> Path.join("helloworld.txt")
    assert File.exists?(filen)

  end

end
