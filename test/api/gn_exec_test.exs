defmodule GnExecTest do
  use ExUnit.Case, async: true
  use Maru.Test, for: GnServer.Router.GnExec
  # use Maru.Router, make_plug: true

  test "/echo_cmd/hellox" do
    res = conn(:get, "/echo_cmd/hellox") |> make_response
    %Plug.Conn{resp_body: value} = res
    assert Poison.decode!(value) == "hellox\n"
  end

end
