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
    # IO.inspect(res)
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == %{"submit" => "ok"}
  end

end
