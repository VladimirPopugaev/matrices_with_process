defmodule Servers.MatrixProcess do
  @moduledoc """

  A module that represents the behavior of the process that is responsible for working
  with the matrix. It performs actions with matrices and sends requests to save changes.

  """
  alias Servers.FileSupervisor
  alias Matrix.SquareMatrix

  use GenServer

  # The number of elements of one matrix row, after which the division into several processes begins
  @async_count_row 1_000_000
  # The number of matrix rows that are processed by one process
  @count_row_at_one_process 100_000

  # ###########################################
  # INTERFACE FUN
  # ###########################################

  @doc """

  Starts the process for processing matrices. Takes as an argument the name of the matrix to identify the process.

  ## Params:
    - matrix_name: string with name of matrix for current process

  """
  @spec start_link(String.t()) :: {:ok, pid()} | {:error, any()}
  def start_link(matrix_name) do
    GenServer.start_link(__MODULE__, matrix_name, name: via_tuple(matrix_name))
  end

  defp via_tuple(matrix_name) do
    Servers.ProcessRegistry.via_tuple({__MODULE__, matrix_name})
  end

  @doc """

  Sends a synchronous request to the process responsible for the matrix named `matrix_name`. It
  takes as input the number of the row to be returned.

  If successful, it returns success tuple `{:ok, row}`. Otherwise it returns error tuple
  `{:error, message}`.

  ## Params:
    - matrix_name: string with name of matrix (for indentity process)
    - index: is the index of the row you want to get

  """
  @spec get_row(String.t(), non_neg_integer()) :: {:ok, list()} | {:error, String.t()}
  def get_row(matrix_name, index) do
    GenServer.call(via_tuple(matrix_name), {:get_row, index})
  end

  @doc """

  Sends a synchronous request to the process responsible for the matrix named `matrix_name`.
  Accepts the index of the row to be replaced and the new row to be inserted.
  If successful, updates the matrix and writes new data to the file. If the update fails, the matrix
  remains unchanged.

  Returns the structure `%SquareMatrix{}`

  ## Params:
    - matrix_name: string with name of matrix (for indentity process)
    - new_row: list with elements for inserting
    - index: is the index of the row you want to set

  """
  @spec set_row(String.t(), list(), non_neg_integer()) :: %SquareMatrix{}
  def set_row(matrix_name, new_row, index) do
    GenServer.call(via_tuple(matrix_name), {:set_row, new_row, index})
  end

  @doc """

  Sends a synchronous request to the process responsible for the matrix named `matrix_name`.
  The matrix stored in the process state is sorted in ascending order (only the rows are sorted).

  If the number of rows is greater than `@async_count_row`, then the number of processes is equal
  (number of rows in matrix / `@count_row_at_one_process`). Otherwise sorting is done in one
  process. Sorting results are saved to file (asynchronous query) and set as new process state.

  ## Params:
    - matrix_name: string with name of matrix (for indentity process)

  """
  @spec sort_matrix(String.t()) :: %SquareMatrix{}
  def sort_matrix(matrix_name) do
    GenServer.call(via_tuple(matrix_name), :sort_matrix)
  end

  @doc """

  Sends a synchronous request to the process responsible for the matrix named `matrix_name`.
  Takes a new process state as input, sets it and saves it to a file.

  ## Params:
    - matrix_name: string with name of matrix (for indentity process)
    - new_struct: `%SquareMatrix{}` struct for new state of process

  """
  @spec set_matrix(String.t(), %SquareMatrix{}) :: %SquareMatrix{}
  def set_matrix(matrix_name, new_struct) do
    GenServer.call(via_tuple(matrix_name), {:set_matrix, new_struct})
  end

  # ###########################################
  # IMPLEMENTATION FUNCTIONS
  # ###########################################

  @doc """

  Initializes the initial state for the new process. Accepts a matrix name, checks for a file
  and past state. If there is a file, the initial state is the last saved file with that name.
  Otherwise it creates a default matrix (1x1).

  ## Params:
    - matrix_name: string with name of matrix for identify process

  """
  @impl GenServer
  @spec init(String.t()) :: {:ok, {String.t(), %SquareMatrix{}}}
  def init(matrix_name) do
    IO.puts("Starting matrix process for #{matrix_name}")

    {:ok, {matrix_name, FileSupervisor.get_content(matrix_name) || SquareMatrix.new_matrix()}}
  end

  @impl GenServer
  def handle_call({:get_row, index}, _from, {_matrix_name, matrix} = state) do
    {:reply, SquareMatrix.get_row(matrix, index), state}
  end

  @impl GenServer
  def handle_call({:set_row, new_row, index}, _from, {matrix_name, matrix}) do
    new_matrix =
      case SquareMatrix.set_row(matrix, new_row, index) do
        %SquareMatrix{} = updated_matrix -> updated_matrix
        {:error, _} -> matrix
      end

    FileSupervisor.save_matrix(matrix_name, new_matrix)

    {:reply, new_matrix, {matrix_name, new_matrix}}
  end

  def handle_call(:sort_matrix, _from, {matrix_name, matrix}) do
    sorted_matrix =
      cond do
        matrix.dim >= @async_count_row -> async_sort_matrix(matrix)
        true -> SquareMatrix.full_sort_matrix(matrix)
      end

    FileSupervisor.save_matrix(matrix_name, sorted_matrix)

    {:reply, sorted_matrix, {matrix_name, sorted_matrix}}
  end

  def handle_call({:set_matrix, new_state}, _from, {matrix_name, _matrix}) do
    FileSupervisor.save_matrix(matrix_name, new_state)

    {:reply, new_state, {matrix_name, new_state}}
  end

  # Splits the full matrix into submatrices with the number of rows equal to `@count_row_at_one_process`.
  # Then it runs asynchronous tasks according to the number of resulting submatrices, and then collects
  # the result in the structure `%SquareMatrix{}`.
  defp async_sort_matrix(matrix) do
    sorted_array =
      Helpers.Helper.sublists_from_list(matrix.array_elems, @count_row_at_one_process)
      |> Enum.map(&Task.async(fn -> SquareMatrix.full_sort_matrix(&1) end))
      |> Enum.reduce([], fn task, acc -> acc ++ Task.await(task) end)

    %{matrix | array_elems: sorted_array}
  end
end
