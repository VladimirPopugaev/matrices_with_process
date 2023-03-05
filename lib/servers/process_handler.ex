defmodule Servers.ProcessHandler do
  @moduledoc """

  A process that monitors the matrix processing (see `Servers.MatrixProcess`). If the matrix
  processing has ended, it starts it again, independent of the other processes. It dynamically
  registers new processes.

  """

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

  Launches a dynamic supervisor to keep track of the matrix processing.

  """
  @spec start_link() :: {:ok, pid()} | {:error, any()}
  def start_link() do
    IO.puts("Starting supervisor for matrix processes")

    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  @doc """

  It takes a matrix name as input and starts a new matrix handle process,
  passing there the name of the matrix.

  ## Params:
    - matrix_name: string with name of matrix (for indentity matrix handle process)

  """
  @spec start_child(String.t()) :: {:ok, pid()} | {:error, any()}
  def start_child(matrix_name) do
    DynamicSupervisor.start_child(__MODULE__, {Servers.MatrixProcess, matrix_name})
  end

  @doc """

  Starts a new matrix handle process or controls that a process has already been started. Returns an
  identifier to refer to the process.

  ## Params:
    - matrix_name: string with name of matrix (for indentity matrix handle process)

  """
  @spec handle_process(String.t()) :: String.t()
  def handle_process(matrix_name) do
    start_child(matrix_name)

    matrix_name
  end
end
