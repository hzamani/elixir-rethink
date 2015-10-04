defmodule Rethink.Query do
  import RQL

  # Control Structures

  @doc "Construct a ReQL datum from a native value."
  def datum(value) when is_list(value) do
    make_list(Enum.map(value, &datum/1))
  end

  def datum(value) when is_tuple(value) do
    datum(Tuple.to_list(value))
  end

  def datum(value) when is_map(value) do
    Enum.into value, %{}, fn {key, value} ->
      {key, datum(value)}
    end
  end

  def datum(value), do: value

  @doc "Construct a ReQL list (array) from a native list"
  defterm :make_list, 2, [list], when: is_list(list), do: list

  # Math and logic

  @doc "Test if values are equal."
  defterm :eq, 17, [values], when: is_list(values), do: values

  @doc "Test if a and b are equal"
  defterm :eq, 17, [a,b]

  @doc "Test if there is an unequal value in list"
  defterm :ne, 18, [values], when: is_list(values), do: values

  @doc "Test if a and b are unequal"
  defterm :ne, 18, [a,b]

  @doc "Compare values, testing if the left-most value is less than the right-most."
  defterm :lt, 19, [values], when: is_list(values), do: values

  @doc "Compare values, testing if the left-hand value is less than the right-hand."
  defterm :lt, 19, [a,b]

  @doc "Compare values, testing if the left-most value is less than or equal to the right-most."
  defterm :le, 20, [values], when: is_list(values), do: values

  @doc "Compare values, testing if the left-hand value is less than or equal to the right-hand."
  defterm :le, 20, [a,b]

  @doc "Compare values, testing if the left-most value is greater than the right-most."
  defterm :gt, 21, [values], when: is_list(values), do: values

  @doc "Compare values, testing if the left-hand value is greater than the right-hand."
  defterm :gt, 21, [a,b]

  @doc "Compare values, testing if the left-most value is greater than or equal to the right-most."
  defterm :ge, 22, [values], when: is_list(values), do: values

  @doc "Compare values, testing if the left-hand value is greater than or equal to the right-hand."
  defterm :ge, 22, [a,b]

  @doc "Compute the logical inverse “not” of an expression."
  defterm :logical_not, 23, [bool]

  @doc "Compute the logical “or” of values."
  defterm :logical_or, 66, [values], when: is_list(values), do: values

  @doc "Compute the logical “or” of two values."
  defterm :logical_or, 66, [a,b]

  @doc "Compute the logical “and” of values."
  defterm :logical_and, 67, [values], when: is_list(values), do: values

  @doc "Compute the logical “and” of two values."
  defterm :logical_and, 67, [a,b]

  @doc "Sum numbers, or concatenate strings or lists."
  defterm :add, 24, [args], when: is_list(args), do: args

  @doc "Sum two numbers, or concatenate two strings or lists."
  defterm :add, 24, [a,b]

  @doc "Subtract more numbers from first one."
  defterm :sub, 25, [numbers], when: is_list(numbers), do: numbers

  @doc "Subtract two numbers."
  defterm :sub, 25, [a,b]

  @doc "Multiply numbers"
  defterm :mul, 26, [numbers], when: is_list(numbers), do: numbers

  @doc "Multiply two numbers, or make a periodic list."
  defterm :mul, 26, [a,b]

  @doc "Divide two numbers."
  defterm :divide, 27, [numbers], when: is_list(numbers), do: numbers

  @doc "Divide first number by others."
  defterm :divide, 27, [a,b]

  @doc "Find the remainder when dividing two numbers."
  defterm :mod, 28, [a,b]

  @doc "Generate a random float number in the range [0,1)"
  defterm :random, 151, []

  @doc "Generate a random number in the range [0,x)"
  defterm :random, 151, [x], options: true

  @doc "Generate a random number in the range [x,y)"
  defterm :random, 151, [x,y], options: true

  @doc """
  Rounds the given value down, returning the largest integer value
  less than or equal to the given value (the value’s floor).
  """
  defterm :floor, 183, [value]

  @doc """
  Rounds the given value up, returning the smallest integer value
  greater than or equal to the given value (the value’s ceiling).
  """
  defterm :ceil, 184, [value]

  @doc "Rounds the given value to the nearest whole integer."
  defterm :reround, 185, [value]
end
