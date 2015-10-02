defmodule Rethink do

  alias RQL.Response
  alias Rethink.Connection

  defmacro __using__(_opts) do
    quote do
      import Rethink
      import Rethink.Query
      import Rethink.Function
    end
  end

  def connect(opts \\ []) do
    opts = Keyword.put_new(opts, :name, Connection)
    {:ok, conn} = Connection.start_link(opts)
    conn
  end

  def run(query, conn \\ Connection, _opts \\ []) do
    {_token, response} = GenServer.call(conn, {:query, query})
    case response do
      %Response{type: :success_atom, value: [value]} -> {:ok, value}
      %Response{type: :success_sequence, value: seq} -> {:ok, seq}
      %Response{type: :runtime_error, error: error, value: [message]} ->
        {:error, error, message}
      x -> x
    end
  end
end
