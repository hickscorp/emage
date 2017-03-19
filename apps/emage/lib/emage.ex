defmodule EMage do
  @moduledoc false

  @type token :: String.t
  @type url :: String.t
  @type hash :: String.t
  @type filename :: String.t
  @type via :: {:via, Registry, {atom, any}}
  @type supervise_spec :: {:ok, {:supervisor.sup_flags, [Supervisor.Spec.spec]}} | :ignore

  @spec hash(String.t) :: hash
  def hash(url) do
    :md5
      |> :crypto.hash(url)
      |> Base.encode16
  end

  @spec registry(String.t, token) :: any
  def registry(mod, token) do
    id = :"EMage.Registry.#{mod}.#{token}"
    Supervisor.Spec.worker Registry, [:unique, id], id: id
  end
end
