defmodule RQL.Term do
  defstruct [:type, :code, args: [], options: []]
end

defimpl Inspect, for: RQL.Term do
  def inspect(%RQL.Term{type: type, args: [], options: []}, _opts) do
    "#T{:#{type}}"
  end
  def inspect(%RQL.Term{type: type, args: args, options: []}, _opts) do
    "#T{:#{type} #{inspect args}}"
  end
  def inspect(%RQL.Term{type: type, args: args, options: options}, _opts) do
    "#T{:#{type} #{inspect args}, #{inspect options}}"
  end
end

defimpl Poison.Encoder, for: RQL.Term do
  def encode(%RQL.Term{code: code, args: args, options: []}, opts) do
    Poison.Encoder.List.encode([code, args], opts)
  end
  def encode(%RQL.Term{code: code, args: args, options: options}, opts) do
    optargs = options
      |> Enum.map(fn
        {key, value} -> {key, value}
        key          -> {key, true}
      end)
      |> Enum.into(%{})
    Poison.Encoder.List.encode([code, args, optargs], opts)
  end
end
