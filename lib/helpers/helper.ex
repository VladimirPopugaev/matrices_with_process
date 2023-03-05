defmodule Helpers.Helper do
  @moduledoc """

  Module with additional functions that are not directly related to structures.

  """

  @doc """

  Divides the list into sublists with the number of items equal to the second parameter.

  ## Params:
    - list: list for spliting
    - amount: number of items in one sublist

  ## Examples
    iex> sublists_from_list([1,2,3,4,5,6], 3)
    [[1,2,3], [4,5,6]]

    iex> sublists_from_list([1,2,3,4,5,6], 4)
    [[1,2,3,4], [5,6]]

  """
  @spec sublists_from_list(list(), non_neg_integer()) :: list(list())
  def sublists_from_list(list, amount) do
    number_of_sublist = floor(length(list) / amount)

    Enum.map(0..number_of_sublist, fn x ->
      sublist_from_list(list, x * amount, amount)
    end)
    |> Enum.reject(fn list -> list == [] end)
  end

  # Trims the list starting with `index_start`. Leaves the number of items equal to `amount`.
  defp sublist_from_list(list, index_start, amount) do
    Enum.slice(list, index_start, amount)
  end
end
