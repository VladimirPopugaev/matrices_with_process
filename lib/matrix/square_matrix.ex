defmodule Matrix.SquareMatrix do
  @moduledoc """

  A module that defines the structure of a square matrix. Contains matrix dimension n and elements as an array of arrays.

  """

  defstruct dim: 1, array_elems: [[1]]

  @doc """

  Creates a new matrix from the passed parameters.

  A matrix is valid if the number of characters in a row is equal to the passed dimensionality,
  and if the number of rows is equal to the dimensionality.

  ## Params:
    - dimesion: the dimensionality of the matrix (the length of each of its rows)
    - array_elems: a list that contains the matrix rows as a list

  """
  @spec new_matrix(non_neg_integer(), list(list())) ::
          %Matrix.SquareMatrix{} | {:error, String.t()}
  def new_matrix(dimension \\ 1, array_elems \\ [[1]]) do
    cond do
      length(array_elems) == dimension and matrix_valid?(dimension, array_elems) ->
        %Matrix.SquareMatrix{
          dim: dimension,
          array_elems: array_elems
        }

      true ->
        {:error, "Not square matrix"}
    end
  end

  # Checks that the matrix rows are the same length as the passed dimension.
  # Returns true if all the row of matrix are valid, otherwise it returns false.
  defp matrix_valid?(dimension, array_elems),
    do: recursive_check_valid?(dimension, array_elems, true)

  defp recursive_check_valid?(_, _, false), do: false
  defp recursive_check_valid?(_, [], true), do: true

  defp recursive_check_valid?(dimension, [row | tail], true),
    do: recursive_check_valid?(dimension, tail, length(row) == dimension)

  @doc """

  Outputs a square matrix to the console.

  ## Params:
    - square_matrix: matrix for printing

  """
  @spec print_matrix(%Matrix.SquareMatrix{}) :: any()
  def print_matrix(square_matrix) do
    Enum.map(square_matrix.array_elems, &print_one_line/1)
  end

  defp print_one_line(array) do
    Enum.map(array, &IO.write(to_string(&1) <> "\t"))
    IO.write("\n")
  end

  @doc """

  Returns the row with the given index from the matrix. If there is no string, it returns an error.

  ## Params:
    - matrix: input matrix
    - index: number of row in matrix (from 0 to length - 1)

  """
  @spec get_row(%Matrix.SquareMatrix{}, non_neg_integer()) ::
          {:ok, list(integer())} | {:error, String.t()}
  def get_row(matrix, index) do
    case Enum.at(matrix.array_elems, index) do
      nil -> {:error, "There is no row with this index in the matrix"}
      value -> {:ok, value}
    end
  end

  @doc """

  It takes `%SquareMatrix{}` structure as input and updates it with one row with index equal to `index`.

  If successful, it returns updated structure `%SquareMatrix{}`. Otherwise it returns error tuple
  `{:error, message}`.

  ## Params:
    - matrix: `%SquareMatrix{}` struct for updating
    - new_row: list with new elements of row for inserting instead old row
    - index: index of row in matrix

  """
  @spec set_row(%Matrix.SquareMatrix{}, list(integer()), non_neg_integer()) ::
          %Matrix.SquareMatrix{} | {:error, String.t()}
  def set_row(matrix, new_row, index) do
    cond do
      matrix.dim == length(new_row) ->
        updated_matrix = List.replace_at(matrix.array_elems, index, new_row)

        %{matrix | array_elems: updated_matrix}

      true ->
        {:error, "This row does not match the size of the matrix"}
    end
  end

  @doc """

  Takes a matrix row as input and returns it sorted.

  ## Params:
    - matrix_row: row of matrix

  """
  @spec sort_matrix_row!(list(integer())) :: list(integer())
  def sort_matrix_row!(matrix_row) do
    Enum.sort(matrix_row)
  end

  @doc """

  Takes `%SquareMatrix{}` structure, extracts string with index equal to `index`. Sorts the
  string and then sets it back into the matrix.

  If sorting is successful, it returns updated `%SquareMatrix{}` structure. Otherwise it returns
  error tuple `{:error, message}`.

  ## Params:
    - matrix: `%SquareMatrix{}` struct for sorting
    - index: index of row for sorting

  """
  @spec sort_matrix_row(%Matrix.SquareMatrix{}, non_neg_integer()) :: %Matrix.SquareMatrix{}
  def sort_matrix_row(%Matrix.SquareMatrix{} = matrix, index) do
    with {:ok, row} <- get_row(matrix, index),
         sotred_row <- sort_matrix_row!(row) do
      set_row(matrix, sotred_row, index)
    else
      {:error, _message} = error -> error
    end
  end

  @doc """

  If a structure `%Matrix.SquareMatrix{}` is passed, it sorts and returns the updated structure.

  If a list consisting of lists with matrix elements is passed, it sorts and also returns the list.

  ## Params:
    - matrix: `%SquareMatrix{}` struct or list with lists for sorting

  """
  @spec full_sort_matrix(%Matrix.SquareMatrix{} | list()) :: %Matrix.SquareMatrix{} | list()
  def full_sort_matrix(%Matrix.SquareMatrix{} = matrix) do
    sorted_matrix =
      for row <- matrix.array_elems do
        sort_matrix_row!(row)
      end

    %{matrix | array_elems: sorted_matrix}
  end

  def full_sort_matrix(matrix) when is_list(matrix) do
    for row <- matrix do
      sort_matrix_row!(row)
    end
  end
end
