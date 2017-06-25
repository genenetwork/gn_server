defmodule TokenTest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.Router.Token

  test "Register token with /token/get" do
    %Plug.Conn{resp_body: token} =
      conn(:post, "/token/get", %{"userid" => "user", "projectid" => "token_test_input"})
    |> make_response
    assert token == "YVJjOoAGNks3bib1vaKq7B9TOO86zn1fwn2MpI--GWQ="
  end

  test "/token/remove" do
    %Plug.Conn{resp_body: token} =
      conn(:post, "/token/get", %{"userid" => "user", "projectid" => "token_test_input"})
    |> make_response
    assert token == "YVJjOoAGNks3bib1vaKq7B9TOO86zn1fwn2MpI--GWQ="
    %Plug.Conn{resp_body: res} =
      conn(:post, "/token/remove/" <> token, %{"userid" => "user", "projectid" => "token_test_input" })
    |> make_response
    assert Poison.decode!(res) == ["ok"]
  end
end
