defmodule Rethink.Function do
  alias Rethink.Query
  alias Rethink.Scope
  alias RQL.Term

  defmacro fun(expr) do
    create_function([], expr)
  end

  defmacro fun(x, expr) do
    create_function([x], expr)
  end

  defmacro fun(x,y, expr) do
    create_function([x,y], expr)
  end

  defmacro fun(x,y,z, expr) do
    create_function([x,y,z], expr)
  end

  defmacro fun(x,y,z,t, expr) do
    create_function([x,y,z,t], expr)
  end

  defmacro args ~> exper do
    create_function(args, exper)
  end

  def create_function(args, block) do
    {:ok, scope} = Scope.start_link
    func = create_function(args, block, scope)
    Scope.close(scope)
    func
  end

  defp create_function(args, block, scope) do
    arg_ids = push(args, scope)
    body = build(block, scope)
    Scope.pop(scope)
    quote bind_quoted: [top: body, args: arg_ids] do
      %Term{type: :func, code: 69, args: [[2, args], top]}
    end
  end

  defp push(args, scope) when is_list(args) do
    names = Enum.map(args, fn {name,_,_} -> name end)
    Scope.push(scope, names)
  end

  defp push(arg, scope) do
    push([arg], scope)
  end

  defp op(name, args) do
    quote do
      Query.unquote(name)(unquote(args))
    end
  end

  defp op_splicing(name, args) do
    quote do
      Query.unquote(name)(unquote_splicing(args))
    end
  end

  defp func_op(args, expersion, scope) do
    quote bind_quoted: [ast: create_function(args, expersion, scope)] do
      ast
    end
  end

  defp func_op(args, scope) do
    {args, [expr]} = Enum.split args, -1
    func_op(args, expr, scope)
  end

  defp var(id) do
    quote do
      %Term{type: :var, code: 10, args: [unquote(id)]}
    end
  end

  defp build(ast, scope) do
    Macro.prewalk ast, fn
      {:~>,  _, args} -> func_op(args, scope)
      {:fun, _, args} -> func_op(args, scope)

      {:==,  _, args} -> op(:eq, args)
      {:!=,  _, args} -> op(:ne, args)
      {:<,   _, args} -> op(:lt, args)
      {:<=,  _, args} -> op(:le, args)
      {:>,   _, args} -> op(:gt, args)
      {:>=,  _, args} -> op(:ge, args)
      {:not, _, [x]}  -> op(:logical_not, x)
      {:or,  _, args} -> op(:logical_or, args)
      {:and, _, args} -> op(:logical_and, args)
      {:+,   _, [a,b]} -> op(:add, [a,b])
      {:-,   _, [a,b]} -> op(:sub, [a,b])
      {:*,   _, args} -> op(:mul, args)
      {:/,   _, args} -> op(:divide, args)
      {:rem, _, args} -> op_splicing(:mod, args)

      expr = {name, _, last} when is_atom(last) ->
        case Scope.get(scope, name) do
          {:ok, id}   -> var(id)
          {:error, _} -> expr
        end

      other -> other
    end
  end
end
