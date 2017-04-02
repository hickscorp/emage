defmodule EMage.TokensSupervisor do
  use Supervisor

  @spec start_link :: {:ok, pid} | {:error, any}
  def start_link do
    Supervisor.start_link __MODULE__, :ok, name: __MODULE__
  end

  def init(:ok) do
    IO.puts "=> The main tokens supervisor is starting."
    template = supervisor EMage.Tokervisor, [], restart: :transient
    supervise [template], strategy: :simple_one_for_one
  end
end
