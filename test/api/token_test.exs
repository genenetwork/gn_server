defmodule TokenTest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.Router.Token

  test "/submit/get_token" do
    %Plug.Conn{resp_body: token} =
      conn(:post, "/submit/get_token", %{"tokenid" => "token_test_input"})
    |> make_response

    assert token = "HWYBgUWrINKs9GDyt-e0k-fYqeq7K0hMHCRm8fH7DXA="
  end
end
