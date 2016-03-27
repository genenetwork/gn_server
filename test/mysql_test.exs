defmodule MySQLTest do
  use ExUnit.Case
  # doctest GnServer

  test "the truth" do
    assert 1 + 1 == 2
  end
  test "the truth2" do
    {:ok, pid} = Mysqlex.Connection.start_link(username: "test", database: "test", password: "test", hostname: "localhost")
    {:ok, result} = Mysqlex.Connection.query(pid, "SELECT title FROM posts", [])
    rec = Map.from_struct(result)
    IO.puts :stderr, "HERE"
    lines = rec[:rows]
    for item <- lines do
      {s} = item
      IO.puts s
    end
    # IO.inspect(lines)
    # json(pid, lines)
    nlist = Enum.map(lines, fn(x) -> {s} = x ; s end)
    IO.puts Poison.encode_to_iodata!(nlist)
    true
  end
end
