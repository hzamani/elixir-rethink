defmodule RQL do
  @moduledoc false

  defmacro defterm(name, code, args, opts \\ []) do
    guard = Keyword.get(opts, :when, true)
    block = Keyword.get(opts, :do, args)
    opted = Keyword.get(opts, :options, false)
    define_term(name, code, args, guard, block, opted)
  end

  defp define_term(name, code, args, guard, block, true) do
    quote do
      def unquote(name)(unquote_splicing(args)) when unquote(guard) do
        %RQL.Term{type: unquote(name), args: unquote(block), code: unquote(code)}
      end
      def unquote(name)(unquote_splicing(args), options) when unquote(guard) and is_list(options) do
        %RQL.Term{type: unquote(name), args: unquote(args), options: options, code: unquote(code)}
      end
    end
  end

  defp define_term(name, code, args, guard, block, false) do
    quote do
      def unquote(name)(unquote_splicing(args)) when unquote(guard) do
        %RQL.Term{type: unquote(name), args: unquote(block), code: unquote(code)}
      end
    end
  end
end

