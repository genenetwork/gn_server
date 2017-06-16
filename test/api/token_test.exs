defmodule TokenTest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.Router.Token

  test "/submit/get_token" do
    %Plug.Conn{resp_body: token} =
      conn(:post, "/submit/get_token", %{"userid" => "user", "tokenid" => "token_test_input"})
    |> make_response
    assert token == "YVJjOoAGNks3bib1vaKq7B9TOO86zn1fwn2MpI--GWQ="
  end
end
