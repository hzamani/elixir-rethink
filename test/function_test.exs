defmodule FunctionTest do
  use ExUnit.Case

  import Rethink.Function
  import TestMacros

  test "fun macro" do
    assert func(0, term(:add, [1,2])) = fun 1 + 2
    assert func(1, term(:mul, [var(1), var(1)])) = fun x, x * x
    assert func(2, term(:eq,  [var(1), var(2)])) = fun x,y, x == y
    assert func(2, term(:sub, [var(1), var(2)])) = fun x,y, x - y
  end

  test "fun macro with subscopes" do
    assert func(1, func(2, 1, var(1))) = fun(x, fun(y, x))
    assert func(1, term(:add, [func(2, 2, var(2)), var(1)])) = fun(x, fun(x, y, x) + x)
  end
end
