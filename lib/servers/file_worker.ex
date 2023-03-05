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

  @doc """

  Starts a process for working with files. Calls the `init/1` function.  Accepts the path
  to the folder where the files will be saved and the process id.

  ## Params:
    - storage_folder: string with full path to file storage
    - worker_id: the id with which the file handler will be created

  """
  @spec start_link(tuple()) :: {:ok, pid()} | {:error, any()}
  def start_link({storage_folder, worker_id}) do
    IO.puts("Start file_worker server with id = #{worker_id}")

    GenServer.start_link(__MODULE__, storage_folder, name: via_tuple(worker_id))
  end

  @doc """

  Sends a message to the process to save the file. Processes the data, converts it to binary and saves it.

  ## Params;
    - worker_id: id of process who will save data in file
    - file_name: string with file name where the data will be stored
    - data: `%SquareMatrix{}` struct for saving

  """
  @spec save_matrix(non_neg_integer(), String.t(), %SquareMatrix{}) :: :ok
  def save_matrix(worker_id, file_name, %SquareMatrix{} = data) do
    GenServer.cast(via_tuple(worker_id), {:save_matrix, file_name, data})
  end

  @doc """

  Sends a request to a process with `worker_id` to output data that is stored in a file named
  `file_name`. If file is not found `nil` is returned.

  ## Params;
    - worker_id: id of process who will get data from file
    - file_name: string with file name where the data will come from

  """
  @spec get_content(non_neg_integer(), String.t()) :: %SquareMatrix{} | nil
  def get_content(worker_id, file_name) do
    GenServer.call(via_tuple(worker_id), {:get_content, file_name})
  end

  defp via_tuple(worker_id) do
    Servers.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  # ###########################################
  # IMPLEMENTATION FUNCTIONS
  # ###########################################

  @doc """

  Initializes the initial state of the process.

  ## Params:
    - storage_folder: string with full path to file storage

  """
  @impl GenServer
  def init(storage_folder) do
    {:ok, storage_folder}
  end

  @doc """

  # {:save_matrix, file_name, data}

  Writes the data in the `data` parameter to a file named `file_name`, first converting it into a binary form.

  """
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

  @doc """

  # {:get_content, file_name}

  Tries to read data from a file named `file_name`. If successful converts it from binary form.
  If unsuccessful it returns `nil`.

  """
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
