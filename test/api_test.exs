defmodule APITest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.API

  setup_all do
    {:ok, hello: Poison.encode!(%{"I am": :genenetwork})}
  end

  test "/hey",%{hello: state} do
    # x = conn(:get, "/hey") |> make_response
    IO.inspect state
    %Plug.Conn{resp_body: value} = conn(:get, "/hey") |> make_response
    assert state == value
  end

  test "/", %{hello: state} do
    %Plug.Conn{resp_body: value} = conn(:get, "/") |> make_response
    assert state == value
  end

end