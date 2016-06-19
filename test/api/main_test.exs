defmodule APITest do
  use ExUnit.Case
  use Maru.Test, for: GnServer.API

  setup_all do
    {:ok, hello: Poison.encode!(%{"I am": :genenetwork})}
  end

  test "/hey",%{hello: state} do
    # IO.inspect state
    %Plug.Conn{resp_body: value} = conn(:get, "/hey") |> make_response
    assert state == value
  end

  test "/", %{hello: state} do
    %Plug.Conn{resp_body: value} = conn(:get, "/") |> make_response
    assert state == value
  end

  test "/species" do
    %Plug.Conn{resp_body: value} = conn(:get, "/species") |> make_response
    assert Poison.decode!(value) == [[1,"mouse","Mus musculus"],[4,"human","Homo sapiens"]]
  end

  test "/cross/BXD" do
    %Plug.Conn{resp_body: value} = conn(:get, "/cross/BXD") |> make_response
    assert Poison.decode!(value) == %{"group" => "BXD", "species" => "mouse"}
  end

end
