ExUnit.start()

defmodule TestMacros do
  defmacro expect_to_match(response, [do: query]) do
    quote do
      assert unquote(response) = Rethink.run(unquote(query))
    end
  end

  defmacro expect_to_match(response, query) do
    quote do
      assert unquote(response) = Rethink.run(unquote(query))
    end
  end

  defmacro term(type) do
    quote do: %RQL.Term{type: unquote(type)}
  end

  defmacro term(type, args) do
    quote do: %RQL.Term{type: unquote(type), args: unquote(args)}
  end

  defmacro var(id) do
    quote do: %RQL.Term{type: :var, args: [unquote(id)]}
  end

  defmacro func(first_arg \\ 1, count, top) do
    args = if count > 0 do
      Enum.to_list(first_arg..(first_arg+count-1))
    else
      []
    end
    quote do: %RQL.Term{type: :func, args: [[2,unquote(args)], unquote(top)]}
  end
end
