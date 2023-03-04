defmodule Servers.FileWorker do
  @moduledoc """

  These processes monitor the storage of matrices. It stores the name of the matrix as a
  state. For each new matrix a new process is created to access the database.

  """

  alias Matrix.SquareMatrix
  use GenServer

  # ###########################################
  # INTERFACE FUN
  # ###########################################

  @spec start_link(tuple()) :: {:ok, pid()} | {:error, any()}
  def start_link({storage_folder, worker_id}) do
    IO.puts("Start file_worker server with id = #{worker_id}")

    GenServer.start_link(__MODULE__, storage_folder, name: via_tuple(worker_id))
  end

  def save_matrix(worker_id, file_name, %SquareMatrix{} = data) do
    GenServer.cast(via_tuple(worker_id), {:save_matrix, file_name, data})
  end

  def get_content(worker_id, file_name) do
    GenServer.call(via_tuple(worker_id), {:get_content, file_name})
  end

  defp via_tuple(worker_id) do
    Servers.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  # ###########################################
  # IMPLEMENTATION FUNCTIONS
  # ###########################################

  @impl GenServer
  def init(file_name) do
    {:ok, file_name}
  end

  @impl GenServer
  def handle_cast({:save_matrix, file_name, data}, storage_folder) do
    :ok = save_csv(storage_folder, file_name, data)

    {:noreply, storage_folder}
  end

  defp save_csv(storage_folder, file_name, data) do
    try do
      file_path(storage_folder, file_name)
      |> File.write!(:erlang.term_to_binary(data))

      :ok
    rescue
      _error -> :error
    end
  end

  @impl GenServer
  def handle_call({:get_content, file_name}, _from, storage_folder) do
    {:reply, get_content_of_file(storage_folder, file_name), storage_folder}
  end

  defp get_content_of_file(storage_folder, file_name) do
    file_data =
      file_path(storage_folder, file_name)
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
