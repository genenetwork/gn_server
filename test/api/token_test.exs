defmodule TokenTest do
  use ExUnit.Case, async: true

  test "parser test" do
    defmodule Test3 do
      use Maru.Router, make_plug: true

      plug Plug.Parsers, [
        parsers: [Plug.Parsers.URLENCODED, Plug.Parsers.JSON, Plug.Parsers.MULTIPART],
        pass: ["*/*"],
        json_decoder: Poison
      ]

      params do
        requires :foo
      end
      post do
        json(conn, params)
      end
    end

    defmodule TestTest3 do
      use Maru.Test, root: TokenTest.Test3

      def test do
        build_conn()
        |> Plug.Conn.put_req_header("content-type", "application/json")
        |> put_body_or_params(~s({"foo":"bar"}))
        |> post("/")
        |> json_response
      end
    end

    TestTest3.test
    assert %{"foo" => "bar"} = TestTest3.test
  end

  test "Register token with /token/get" do

    defmodule TestTestZ do
      use Maru.Test, root: GnServer.Router.Token
      use Maru.Router
      use Plug.Test

      def test1 do
        # %Plug.Conn{resp_body: token} =
        # build_conn()
        # |> put_body_or_params(~s({"userid":"user"}))
        # |> put_body_or_params(~s( %{"userid" => "user", "projectid" => "token_test_input"} ))
        conn(:post,"/token/value", %{"userid" => "user", "projectid" => "token_test_input"})
        # token
      end

      def test do
        build_conn()
        |> Plug.Conn.put_req_header("content-type", "application/json")
        # |> put_body_or_params(~s( %{"userid" => "user", "projectid" => "token_test_input"} ))
        # |> post("/token/get")
        |> json_response
      end

    end
    IO.puts("!!!")
    IO.inspect(TestTestZ.test1())
    # IO.inspect(TestTestZ.test())
  end
    # %Plug.Conn{resp_body: token} =
    # token =
    #   conn(:post, "/token/get", %{"userid" => "user", "projectid" => "token_test_input"})

    # %Plug.Conn{resp_body: token} =
    # token =
    #   post("/token/get", %{"userid" => "user", "projectid" => "token_test_input"})
    # |> text_response
    # IO.inspect("!!!")
    # IO.inspect(token)
    # assert token == "YVJjOoAGNks3bib1vaKq7B9TOO86zn1fwn2MpI--GWQ="
end

  # test "/token/remove" do
  #   %Plug.Conn{resp_body: token} =
  #     post("/token/get", %{"userid" => "user", "projectid" => "token_test_input"})
  #   |> text_response
  #   assert token == "YVJjOoAGNks3bib1vaKq7B9TOO86zn1fwn2MpI--GWQ="
  #   %Plug.Conn{resp_body: res} =
  #     post("/token/remove/" <> token, %{"userid" => "user", "projectid" => "token_test_input" })
  #   |> text_response
  #   assert Poison.decode!(res) == ["ok"]
  # end
