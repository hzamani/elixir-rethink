defmodule ConnectionTest do
  use ExUnit.Case

  setup_all do
    {:ok, conn} = Rethink.Connection.start_link
    {:ok, %{conn: conn}}
  end

  test "connect to rethinkdb server", %{conn: conn} do
    assert is_pid(conn)
  end

  test "run queries over connection", %{conn: conn} do
    {_token, resp} = GenServer.call conn, {:query, "foo"}
    assert is_map(resp)
    assert %{__struct__: RQL.Response} = resp
    assert ["foo"] = resp.value
  end
end
