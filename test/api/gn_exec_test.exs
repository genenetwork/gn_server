defmodule GnExecTest do
  use ExUnit.Case, async: true
  use Maru.Test # , for: GnServer.Router.GnExec
  # use Maru.Router, make_plug: true

  test "/echo_cmd/hellox" do
    res = get("/echo_cmd/hellox") |> text_response
    assert Poison.decode!(res) == "hellox\n"
  end

end
