defmodule RQL.Response do
  defstruct [:type, :error, :notes, :token, :value, :backtrace, :profile]

  def parse(map) do
    %RQL.Response{
      type: responce_type(map["t"]),
      error: error_type(map["e"]),
      notes: map["n"] |> Enum.map(&note_type/1),
      token: map["t"],
      value: map["r"],
      backtrace: map["b"],
      profile: map["p"]
    }
  end

  def success?(%RQL.Response{type: type}) do
    type in [:success_atom, :success_sequence, :success_partial]
  end

  def error?(%RQL.Response{type: type}) do
    type in [:client_error, :complete_error, :runtime_error]
  end

  def wait?(%RQL.Response{type: type}) do
    type == :wait_complete
  end

  defp responce_type(n) do
    case n do
      1  -> :success_atom
      2  -> :success_sequence
      3  -> :success_partial
      4  -> :wait_complete
      16 -> :client_error
      17 -> :complete_error
      18 -> :runtime_error
    end
  end

  defp error_type(n) do
    case n do
      1000000 -> :internal
      2000000 -> :resource_limit
      3000000 -> :query_logic
      3100000 -> :non_existance
      4100000 -> :op_failed
      4200000 -> :op_indeterminate
      5000000 -> :user
      nil -> nil
    end
  end

  defp note_type(n) do
    case n do
      1 -> :sequence_feed
      2 -> :atom_feed
      3 -> :order_by_limit_feed
      4 -> :unioned_feed
      5 -> :includes_states
    end
  end
end
