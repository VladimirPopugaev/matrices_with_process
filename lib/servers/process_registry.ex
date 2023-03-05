defmodule Servers.ProcessRegistry do
  @moduledoc """

  This module is responsible for registering the processes of the different modules in a
  uniform way, with the possibility to access them without knowing their pid.

  """

  @doc """

  Starts the process to register other processes. Keys can only be unique and each process will
  only be associated with one key.

  """
  @spec start_link() :: {:ok, pid()} | {:error, any()}
  def start_link() do
    IO.puts("Start server for process registry")
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  @doc """

  Determine what kind of processes will be registered. Creates a tuple, which states that the
  registration will be performed by the Registry module.

  ## Params:
    - key: tuple or any value for registration process

  """
  @spec via_tuple(tuple()) :: tuple()
  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  @doc """

  This function defines the specification of the supervisor process to run from other modules
  with a call to `Supervisor.start_child`)

  ## Params:
    - opts

  """
  @spec child_spec(any()) :: map()
  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end

  @doc """

  The function returns the pid of the process which is registered under the passed term.

  ## Params:
    search_tuple: term with identity name of process

  """
  @spec whereis(tuple()) :: pid()
  def whereis(search_tuple) do
    list_of_pid = Registry.lookup(__MODULE__, search_tuple)
    {pid, _value} = List.first(list_of_pid)

    pid
  end
end
