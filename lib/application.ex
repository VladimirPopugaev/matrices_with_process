defmodule Matrix.Application do
  use Application

  @doc """

  Everything in this function is executed before the application starts.

  """
  @spec start(any(), any()) :: {:ok, pid} | {:error, {:already_started, pid} | {:shutdown, term} | term}
  def start(_type, _args) do
    Matrix.System.start()
  end
end
