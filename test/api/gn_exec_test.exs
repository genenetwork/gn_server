defmodule GnExecTest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.Router.GnExec

  test "/echo_cmd/hellox" do
    res = conn(:get, "/echo_cmd/hellox") |> make_response
    # IO.inspect(res)
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) ==
      "hellox\n"
  end

end
