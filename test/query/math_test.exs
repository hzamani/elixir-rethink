defmodule MathTest do
  use ExUnit.Case

  import Rethink.Query
  import TestMacros

  setup_all do
    Rethink.connect
    :ok
  end

  test "add" do
    expect_to_match {:ok, 5}, add(2,3)
    expect_to_match {:ok, 35}, add([2,3,10,20])
    expect_to_match {:ok, "this is a test"}, add(["this ", "is ", "a test"])
    expect_to_match {:ok, [1,2,3,4]}, add(datum([1,2,3]), datum([4]))
  end

  test "sub" do
    expect_to_match {:ok, 5}, sub(8,3)
    expect_to_match {:ok, 4}, sub([10,2,3,1])
  end

  test "mul" do
    expect_to_match {:ok, 24}, mul(8,3)
    expect_to_match {:ok, 60}, mul([10,2,3,1])
    expect_to_match {:ok, [1,2,1,2,1,2,1,2,1,2]}, mul(5, datum([1,2]))
  end

  test "divide" do
    expect_to_match {:ok, 2.5}, divide(10,4)
    expect_to_match {:ok, 1.25}, divide([10,2,4,1])
  end

  test "mod" do
    expect_to_match {:ok, 2}, mod(8,3)
  end

  test "logical_and" do
    expect_to_match {:ok, true}, logical_and(true, true)
    expect_to_match {:ok, false}, logical_and(true, false)
    expect_to_match {:ok, 4}, logical_and([1,2,3,4])
    expect_to_match {:ok, false}, logical_and([1,2,3,false,4])
  end

  test "logical_or" do
    expect_to_match {:ok, true}, logical_or(true, true)
    expect_to_match {:ok, true}, logical_or(true, false)
    expect_to_match {:ok, 1}, logical_or([1,2,3,4])
    expect_to_match {:ok, 1}, logical_or([false,1,2,3,false,4])
  end

  test "logical_not" do
    expect_to_match {:ok, false}, logical_not(true)
    expect_to_match {:ok, true}, logical_not(false)
  end

  test "eq" do
    expect_to_match {:ok, true}, eq(2,2)
    expect_to_match {:ok, true}, eq([1,1,1,1])
    expect_to_match {:ok, false}, eq("name", "example")
    expect_to_match {:ok, false}, eq([1,1,1,2,1])
  end

  test "ne" do
    expect_to_match {:ok, false}, ne(2,2)
    expect_to_match {:ok, false}, ne([1,1,1,1])
    expect_to_match {:ok, true}, ne("name", "example")
    expect_to_match {:ok, true}, ne([1,1,1,2,1])
  end

  test "gt" do
    expect_to_match {:ok, false}, gt(2,2)
    expect_to_match {:ok, false}, gt(1,2)
    expect_to_match {:ok, true}, gt(1.9, 1)
    expect_to_match {:ok, true}, gt([5,3,1])
    expect_to_match {:ok, false}, gt([5,3,1,7])
  end

  test "ge" do
    expect_to_match {:ok, true}, ge(2,2)
    expect_to_match {:ok, false}, ge(1,2)
    expect_to_match {:ok, true}, ge(1.9, 1)
    expect_to_match {:ok, true}, ge([5,3,3])
    expect_to_match {:ok, false}, ge([5,3,1.3,7])
  end

  test "lt" do
    expect_to_match {:ok, false}, lt(2,2)
    expect_to_match {:ok, true}, lt(1,2)
    expect_to_match {:ok, false}, lt(1.9, 1)
    expect_to_match {:ok, false}, lt([5,3,1])
    expect_to_match {:ok, false}, lt([5,3,1,7])
  end

  test "le" do
    expect_to_match {:ok, true}, le(2,2)
    expect_to_match {:ok, true}, le(1,2)
    expect_to_match {:ok, false}, le(1.9, 1)
    expect_to_match {:ok, false}, le([5,3,3])
    expect_to_match {:ok, true}, le([1,5,10])
  end

  test "reround" do
    expect_to_match {:ok, 12}, reround(12.324)
    expect_to_match {:ok, 13}, reround(12.624)
  end

  test "ceil" do
    expect_to_match {:ok, 13}, ceil(12.324)
    expect_to_match {:ok, -12}, ceil(-12.324)
  end

  test "floor" do
    expect_to_match {:ok, 12}, floor(12.324)
    expect_to_match {:ok, -13}, floor(-12.324)
  end
end
