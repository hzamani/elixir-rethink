defmodule Rethink.Scope do
  import GenServer

  def start_link(opts \\ []) do
    Rethink.Scope.Server.start_link opts
  end

  def close(scope) do
    cast scope, :stop
  end

  def push(scope, vars) when is_list(vars) do
    call scope, {:push, vars}
  end

  def push(scope, var) do
    call scope, {:push, [var]}
  end

  def pop(scope) do
    cast scope, :pop
  end

  def get(scope, var) do
    call scope, {:get, var}
  end
end

defmodule Rethink.Scope.Server do
  use GenServer

  def start_link(opts \\ []) do
    # state: {stack, level, next_id}
    # stack: [{level, id, var} ...]
    GenServer.start_link __MODULE__, {[], 1}, opts
  end

  def handle_cast(:pop, state = {[],_}) do
    {:noreply, state}
  end

  def handle_cast(:pop, {stack = [{level,_,_}|_], next_id}) do
    stack = pop(stack, level)
    {:noreply, {stack, next_id}}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_call({:push, vars}, _from, {[], next_id}) do
    {ids, state} = push(vars, [], 1, next_id)
    {:reply, ids, state}
  end

  def handle_call({:push, vars}, _from, {stack = [{level,_,_}|_], next_id}) do
    {ids, state} = push(vars, stack, level+1, next_id)
    {:reply, ids, state}
  end

  def handle_call({:get, var}, _from, state = {stack,_}) do
    {:reply, get(stack, var), state}
  end

  defp push(vars, stack, level, next_id) when is_list(vars) do
    Enum.map_reduce vars, {stack, next_id}, fn (var, {tail, id}) ->
      {id, {[{level, id, var}|tail], id + 1}}
    end
  end

  defp pop([], _), do: []
  defp pop(stack = [{level,_,_}|tail], target) do
    if level == target do
      pop(tail, target)
    else
      stack
    end
  end

  defp get([], _), do: {:error, :not_found}
  defp get([{_, id, var} | tail], target) do
    if var == target do
      {:ok, id}
    else
      get(tail, target)
    end
  end
end
