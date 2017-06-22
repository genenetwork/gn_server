defmodule TokenTest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.Router.Token


  test "Register token with /token/get" do
    # curl -X POST -d username="Rob Williams" -d tokenid=projectid http://127.0.0.1:8880/token/get
    %Plug.Conn{resp_body: token} =
      conn(:post, "/token/get", %{"userid" => "user", "tokenid" => "token_test_input"})
    |> make_response
    assert token == "YVJjOoAGNks3bib1vaKq7B9TOO86zn1fwn2MpI--GWQ="
  end

  test "/token/remove" do
    %Plug.Conn{resp_body: res} =
      conn(:post, "/token/remove/YVJjOoAGNks3bib1vaKq7B9TOO86zn1fwn2MpI--GWQ=", %{"userid" => "user"})
    |> make_response
    assert Poison.decode!(res) == ["ok"]
  end
end
