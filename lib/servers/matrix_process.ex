defmodule Servers.MatrixProcess do
  alias Servers.FileSupervisor
  alias Matrix.SquareMatrix

  use GenServer

  # ###########################################
  # INTERFACE FUN
  # ###########################################

  @spec start_link(String.t()) :: {:ok, pid()} | {:error, any()}
  def start_link(matrix_name) do
    # Create new process for storing matrices

    GenServer.start_link(__MODULE__, matrix_name, name: via_tuple(matrix_name))
  end

  defp via_tuple(matrix_name) do
    Servers.ProcessRegistry.via_tuple({__MODULE__, matrix_name})
  end

  @spec get_row(String.t(), non_neg_integer()) :: list()
  def get_row(matrix_name, index) do
    GenServer.call(via_tuple(matrix_name), {:get_row, index})
  end

  @spec set_row(String.t(), list(), non_neg_integer()) :: %SquareMatrix{}
  def set_row(matrix_name, new_row, index) do
    GenServer.call(via_tuple(matrix_name), {:set_row, new_row, index})
  end

  @spec sort_row(String.t(), non_neg_integer()) :: :ok
  def sort_row(matrix_name, index) do
    GenServer.call(via_tuple(matrix_name), {:sort_row, index})
  end

  # ###########################################
  # IMPLEMENTATION FUNCTIONS
  # ###########################################

  @impl GenServer
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

  @impl GenServer
  def handle_call({:sort_row, index}, _from, {matrix_name, matrix}) do
    sort_matrix = SquareMatrix.sort_matrix_row(matrix, index)

    FileSupervisor.save_matrix(matrix_name, sort_matrix)

    {:reply, sort_matrix, {matrix_name, sort_matrix}}
  end
end
