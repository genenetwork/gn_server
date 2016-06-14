defmodule InternalAPITest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.API

  setup_all do
    {:ok, hello: Poison.encode!(%{"I am": :genenetwork, api: :internal})}
  end

  test "int/", %{hello: state} do
    %Plug.Conn{resp_body: value} = conn(:get, "int/") |> make_response
    assert state == value
  end

end
