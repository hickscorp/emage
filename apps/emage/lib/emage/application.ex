defmodule EMage.Application do
  @moduledoc """
  """
  use Application

  @tokens_registry EMage.Registry.Tokens

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Registry, [:unique, @tokens_registry], id: @tokens_registry),
      supervisor(EMage.TokensSupervisor, [])
    ]
    Supervisor.start_link children, strategy: :one_for_one
  end
end
