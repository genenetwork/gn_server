defmodule HeaderTest do
  use ExUnit.Case
  use Plug.Test

  alias GnServers.Headers.CORSRangePlug, as: CORSRangePlug

  test "Add CORS Range header for request with Range" do
    conn = conn(:get, "/")
    |> Plug.Conn.put_req_header("range", "0-10")
    |> CORSRangePlug.call(%{})
    assert(Plug.Conn.get_resp_header(conn, "content-range") == ["bytes 0-4095/4096"])
  end

  test "Do not add CORS Range header for request without Range" do
    conn = conn(:get, "/")
    |> CORSRangePlug.call(%{})
    assert(Plug.Conn.get_resp_header(conn, "content-range") == [])
  end
end
