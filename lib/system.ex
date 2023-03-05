defmodule Matrix.System do
  @moduledoc """

  This module is responsible for the highest level of the application. It provides monitoring
  of logging processes, supervisors and process handlers. If any of the monitored processes
  terminates, it is restarted.

  """

  @doc """

  Starts the supervisor that will monitor the registration process (see `Servers.ProcessRegistry`),
  the supervisor for file processes (see `Servers.FileSupervisor`), and the process that is responsible
  for starting and tracking matrix processing processes (see `Servers.ProcessHandler`).

  """
  @spec start() :: {:ok, pid} | {:error, {:already_started, pid} | {:shutdown, term} | term}
  def start() do
    Supervisor.start_link(
      [
        Servers.ProcessRegistry,
        Servers.FileSupervisor,
        Servers.ProcessHandler
      ],
      strategy: :one_for_one
    )
  end
end
