defmodule EMage.SOTOSupervisor do
  use Supervisor

  @type t :: pid

  # Public API.

  @spec start_link(EMage.token, atom, atom) :: {:ok, SOTOSupervisor.t}
  def start_link(token, mod, sub_reg) do
    name = {:via, Registry, {EMage.Registry.Tokens, {token, sub_reg}}}
    sup = Supervisor.start_link __MODULE__, mod, name: name
    case sup do
      {:ok, pid}                        -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  @spec spec(EMage.token, atom, atom) :: any
  def spec(token, mod, sub_reg) do
    Supervisor.Spec.supervisor EMage.SOTOSupervisor,
                               [token, mod, sub_reg], id: sub_reg
  end

  # GenServer API.

  @spec init(atom) :: EMage.supervise_spec
  def init(mod) do
    IO.puts "-> SOTO supervisor starting for #{inspect mod}."
    template = supervisor mod, [], restart: :transient
    supervise [template], strategy: :simple_one_for_one
  end
end
