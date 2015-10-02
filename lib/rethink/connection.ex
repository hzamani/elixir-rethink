defmodule Rethink.Connection do
  use GenServer

  @version 0x400c2d20 # v0_4
  @protocol 0x7e6970c7 # json
  @init_state %{socket: nil, token: 0, pending: %{}, current: {:start, ""}}

  def start_link(opts \\ []) do
    {args, options} = Keyword.split(opts, [:host, :port, :auth_key])
    GenServer.start_link(__MODULE__, args, options)
  end

  def init(args) do
    host     = Keyword.get(args, :host, 'localhost')
    port     = Keyword.get(args, :port, 28015)
    auth_key = Keyword.get(args, :auth_key, "")

    {:ok, socket} = open_connection(host, port)
    :ok = handshake(socket, auth_key)
    :ok = recive_one_data_message(socket)

    {:ok, %{@init_state | socket: socket}}
  end

  defp recive_one_data_message(socket) do
    :inet.setopts(socket, active: :once)
  end

  defp open_connection(host, port) do
    :gen_tcp.connect(host, port, active: false, mode: :binary)
  end

  defp handshake(socket, auth_key) do
    :ok = :gen_tcp.send(socket, iolist(@version))
    :ok = :gen_tcp.send(socket, iolist(:erlang.iolist_size(auth_key)))
    :ok = :gen_tcp.send(socket, auth_key)
    :ok = :gen_tcp.send(socket, iolist(@protocol))

    case recive_null_terminated(socket) do
      "SUCCESS" -> :ok
      error     -> raise "connection error: #{error}"
    end
  end

  defp iolist(data),     do: << data :: little-size(32) >>
  defp iolist(data, 64), do: << data :: little-size(64) >>

  def handle_call({:query, query}, from, state = %{token: token}) do
    {:ok, encoded_query} = Poison.encode([1, query, %{}])
    send_request(encoded_query, token, from, %{state | token: token + 1})
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state};
  end

  def handle_call(_, state) do
    {:noreply, state}
  end

  defp send_request(query, token, from, state = %{socket: socket, pending: pending}) do
    size = :erlang.size(query)
    payload = [iolist(token, 64), iolist(size), query]
    :ok = :gen_tcp.send(socket, payload)
    {:noreply, %{state | pending: Map.put_new(pending, token, from)}}
  end

  defp recive_null_terminated(socket, acc \\ "") do
    case :gen_tcp.recv(socket, 1) do
      {:ok, "\0"} -> acc
      {:ok, byte} -> recive_null_terminated(socket, acc <> byte)
    end
  end

  def handle_info({:tcp, _socket, data}, state = %{socket: socket}) do
    :ok = recive_one_data_message(socket)
    handle_income(data, state)
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp handle_income(income, state = %{current: {:start, got}}) do
    case got <> income do
      << token :: little-size(64), length :: little-size(32), tail :: binary >> ->
        handle_income("", %{state | current: {token, length, tail}})
      data ->
        {:noreply, %{state | current: {:start, data}}}
    end
  end

  defp handle_income(income, state = %{current: {token, length, got}}) do
    case got <> income do
      << response :: binary-size(length), tail :: binary >> ->
        new_state = reply(token, response, state)
        {:noreply, %{new_state | current: {:start, tail}}}
      data ->
        {:noreply, %{state | current: {token, length, data}}}
    end
  end

  defp reply(token, response, state = %{pending: pending}) do
    parsed = response
    |> Poison.decode!
    |> RQL.Response.parse
    GenServer.reply(pending[token], {token, parsed})
    %{state | pending: Map.delete(pending, token)}
  end
end
