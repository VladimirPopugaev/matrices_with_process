defmodule Servers.FileSupervisor do
  alias Servers.FileWorker
  @storage_path "./csv_storage"
  @pool_size 5

  def start_link() do
    IO.puts("Starting supervisor for file_workers")

    File.mkdir_p!(@storage_path)
    children = Enum.map(1..5, &worker_spec/1)

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    file_worker_spec = {Servers.FileWorker, {@storage_path, worker_id}}

    Supervisor.child_spec(file_worker_spec, id: worker_id)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def save_matrix(file_name, data) do
    file_name
    |> choose_worker()
    |> FileWorker.save_matrix(file_name, data)
  end

  def get_content(file_name) do
    file_name
    |> choose_worker()
    |> FileWorker.get_content(file_name)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
