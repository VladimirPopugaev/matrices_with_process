defmodule Servers.FileWorker do
  @moduledoc """

  These processes monitor the storage of matrices. It stores the name of the matrix as a
  state. For each new matrix a new process is created to access the database.

  """

  alias Matrix.SquareMatrix
  import Servers.MatrixProcess, only: [via_tuple: 2]
  use GenServer

  @storage_path "./csv_storage"

  # ###########################################
  # INTERFACE FUN
  # ###########################################

  @spec start_link(String.t()) :: {:ok, pid()} | {:error, any()}
  def start_link(file_name) do
    IO.puts("Start file_worker server for #{file_name}")

    GenServer.start_link(__MODULE__, file_name, name: via_tuple(__MODULE__, file_name))
  end

  def save_matrix(file_name, %SquareMatrix{} = data) do
    GenServer.cast(via_tuple(__MODULE__, file_name), {:save_matrix, data})
  end

  def get_content(file_name) do
    GenServer.call(via_tuple(__MODULE__, file_name), :get_content)
  end

  # ###########################################
  # IMPLEMENTATION FUNCTIONS
  # ###########################################

  @impl GenServer
  def init(file_name) do
    File.mkdir_p!(@storage_path)

    {:ok, file_name}
  end

  @impl GenServer
  def handle_cast({:save_matrix, data}, file_name) do
    :ok = save_csv(file_name, data)

    {:noreply, file_name}
  end

  defp save_csv(file_name, data) do
    try do
      file_path(@storage_path, file_name)
      |> File.write!(:erlang.term_to_binary(data))

      :ok
    rescue
      _error -> :error
    end
  end

  @impl GenServer
  def handle_call(:get_content, _from, file_name) do
    {:reply, get_content_of_file(file_name), file_name}
  end

  defp get_content_of_file(file_name) do
    file_data =
      file_path(@storage_path, file_name)
      |> File.read()

    case file_data do
      {:ok, data} -> :erlang.binary_to_term(data)
      {:error, _} -> nil
    end
  end

  defp file_path(full_path, file_name) do
    csv_file_name = file_name <> ".csv"
    Path.join(full_path, csv_file_name)
  end
end
