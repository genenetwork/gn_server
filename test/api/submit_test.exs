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
    # IO.puts "====="
    # IO.inspect(res)
    # resp_body: "{\"submit\":\"ok\"}", resp_cookies: %{},
    # resp_headers: [{"cache-control", "max-age=0, private, must-revalidate"},
    # script_name: [], secret_key_base: nil, state: :sent, status: 200}

    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == %{"submit" => "ok"}
    %Plug.Conn{status: status} = res
    # IO.inspect ["*** STATUS",status]
    assert status == 200
  end

  test "/submit/rqtl/control" do
    # res = conn(:put, "/submit/rqtl") |> make_response
    res = conn(:put, "/submit/rqtl/control", %{"Hello world" => nil,
                                                "token" => "4PmJfVN7HBXD4_Py0tf8K1a_OPPoZhIXphpSlcOIuN4=",
                                                "filename" => "helloworld.txt"}) |> make_response
    IO.puts "====="
    IO.inspect(res)
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == %{"submit" => "ok"}
    %Plug.Conn{status: status} = res
    IO.inspect ["*** STATUS",status]
    assert status == 200
  end

end
