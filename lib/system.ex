defmodule Matrix.System do
  def start() do
    Supervisor.start_link(
      [
        Servers.ProcessRegistry,
        Servers.FileSupervisor
      ],
      strategy: :one_for_one
    )
  end
end
