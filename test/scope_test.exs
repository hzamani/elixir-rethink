defmodule ScopeTest do
  use ExUnit.Case

  alias Rethink.Scope

  test "scope functinality" do
    vars1 = ~w[x y z]a
    vars2 = ~w[x t]a
    {:ok, scope} = Scope.start_link

    ids1 = Scope.push scope, vars1
    assert [1,2,3] == ids1
    assert {:ok, 1} = Scope.get(scope, :x)
    assert {:ok, 2} = Scope.get(scope, :y)

    ids2 = Scope.push scope, vars2
    assert [4,5] == ids2
    assert {:ok, 4} = Scope.get(scope, :x)
    assert {:ok, 5} = Scope.get(scope, :t)

    Scope.pop scope
    assert {:ok, 1} = Scope.get(scope, :x)
    assert {:error, :not_found} = Scope.get(scope, :t)

    Scope.push scope, vars1
    assert {:ok, 6} = Scope.get(scope, :x)

    Scope.close scope
  end
end
