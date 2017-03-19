defmodule EMage.Tokervisor do
  use Supervisor

  alias EMage.TokensSupervisor

  # Public API.

  @spec by(EMage.token) :: Tokervisor.t
  def by(token) do
    name  = {:via, Registry, {EMage.Registry.Tokens, token}}
    sup   = Supervisor.start_child TokensSupervisor, [token, name]
    case sup do
      {:ok, pid}                        -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  @spec start_link(EMage.token, EMage.via) :: Tokervisor.t
  def start_link(token, name) do
    Supervisor.start_link __MODULE__, token, name: name
  end

  # Supervisor API.

  @spec init(EMage.token) :: EMage.supervise_spec
  def init(token) do
    IO.puts "-> A token supervisor is starting for #{token}."
    children = [
      EMage.registry("Downloads", token),
      EMage.registry("Processors", token),
      EMage.SOTOSupervisor.spec(token, EMage.Worker.Downloader, :downloads),
      EMage.SOTOSupervisor.spec(token, EMage.Worker.Processor, :processors)
    ]
    supervise children, strategy: :one_for_one
  end
end
