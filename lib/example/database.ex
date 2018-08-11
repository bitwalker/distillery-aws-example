defmodule Example.Database do
  use GenServer
  require Logger

  ## API

  @doc """
  Returns a boolean indicating whether the database is up or not
  """
  def available?() do
    case :ets.lookup(__MODULE__, :up) do
      [] ->
        false
      [{_, nil}] ->
        false
      [{_, pid}] when is_pid(pid) ->
        Process.alive?(pid)
    end
  catch
    _, :badarg ->
      # Table hasn't been created yet
      false
  end

  ## Server

  def start_link() do
    GenServer.start_link(__MODULE__, [self()], name: __MODULE__)
  end

  def init([parent]) do
    Process.flag(:trap_exit, true)
    :ets.new(__MODULE__, [:public, :named_table, :set])
    state = %{parent: parent, pid: nil, ref: nil}
    {:ok, check(state)}
  end

  def handle_info(:check, state) do
    {:noreply, check(state)}
  end
  def handle_info({:EXIT, parent, reason}, %{parent: parent} = state) do
    {:stop, reason, state}
  end
  def handle_info({:DOWN, ref, _type, _pid, reason}, %{ref: ref} = state) do
    # We lost the repo for some reason
    Logger.warn "Example.Repo has crashed: #{inspect reason}"
    # Clear the existing status
    :ets.delete(__MODULE__, :up)
    # Start polling again
    {:noreply, check(%{state | pid: nil, ref: nil})}
  end

  defp check(%{pid: nil} = state) do
    pid = try_start()
    :ets.insert(__MODULE__, {:up, pid})
    Process.send_after(self(), :check, 5_000)
    %{state | pid: pid}
  end
  defp check(%{pid: pid} = state) when is_pid(pid) do
    Process.send_after(self(), :check, 5_000)
    state
  end

  defp try_start() do
    case Example.Repo.start_link([]) do
      {:ok, pid} ->
        pid
      {:error, {:already_started, _pid}} ->
        raise "Wasn't expecting Example.Repo to be started but it was!"
      {:error, reason} ->
        Logger.warn "Unable to start Example.Repo: #{inspect reason}"
        nil
    end
  end
end
