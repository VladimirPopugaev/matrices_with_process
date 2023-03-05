defmodule Servers.FileSupervisor do
  @moduledoc """

  This process starts and monitors 5 processes to handle the file storage. It distributes requests
  by file name hash, which ensures that one file is always handled by the same process.

  """

  alias Servers.FileWorker
  @storage_path "./csv_storage"
  @pool_size 5

  @doc """

  Creates a directory for storing files (if not created) and starts processes (at `@pool_size`)
  to process files (see `Servers.FileWorker`). If one process fails, it restarts without affecting
  the other processes.

  """
  def start_link() do
    IO.puts("Starting supervisor for file_workers")

    File.mkdir_p!(@storage_path)
    children = Enum.map(1..5, &worker_spec/1)

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @doc private: """

       Creates a directory for storing files (if not created) and starts processes (at `@pool_size`)
       to process files (see `Servers.FileWorker`). If one process fails, it restarts without affecting
       the other processes.

       ## Params:
        - worker_id: id of process

       """
  defp worker_spec(worker_id) do
    file_worker_spec = {Servers.FileWorker, {@storage_path, worker_id}}

    Supervisor.child_spec(file_worker_spec, id: worker_id)
  end

  @doc """

  This function defines the specification of the supervisor process to run from other modules
  with a call to `Supervisor.start_child`)

  ## Params:
    - opts

  """
  @spec child_spec(any()) :: map()
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  @doc """

  The file name is used to determine the hash of the file. The hash is used to select the id
  of the handler that will save the data to the file asynchronously.

  ## Params:
    - file_name: string with file name for saving
    - data: `%Matrix.SquareMatrix{}` struct for saving

  """
  @spec save_matrix(String.t(), %Matrix.SquareMatrix{}) :: :ok
  def save_matrix(file_name, data) do
    file_name
    |> choose_worker()
    |> FileWorker.save_matrix(file_name, data)
  end

  @doc """

  The file name is used to determine the hash of the file. The hash is used to select the id
  of the handler that will get the data from the file asynchronously.

  ## Params:
    - file_name: string with file name

  """
  @spec get_content(String.t()) :: %Matrix.SquareMatrix{} | nil
  def get_content(file_name) do
    file_name
    |> choose_worker()
    |> FileWorker.get_content(file_name)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
