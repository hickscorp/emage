defmodule EMage.Future do
  @moduledoc """
  """

  use GenServer

  @type t :: pid
  @type unit :: {atom, list(any)}
  @type result :: any
  @type internal_state :: {:process, unit} | {:processed, result}

  # Public API.

  @spec start_link(atom, any, list) :: {:ok, t} | {:error, {atom, String.t}}
  def start_link(handler, args, opts \\ []) do
    GenServer.start_link __MODULE__, {handler, args}, opts
  end

  @spec process(t) :: :ok
  def process(future) do
    GenServer.cast future, :process
  end

  @spec result(t) :: result
  def result(future) do
    GenServer.call future, :result
  end

  # GenServer API.

  @spec init(unit) :: {:ok, internal_state}
  def init(unit) do
    {:ok, {:process, unit}}
  end

  @spec handle_cast(:process, internal_state) :: {:noreply, internal_state}
  def handle_cast(:process, {:process, {handler, args}} = state) do
    case handler.run args do
      {:ok, result} -> {:noreply, {:processed, result}}
      _             -> {:noreply, state}
    end
  end
  def handle_cast(:process, {:processed, _} = state) do
    {:noreply, state}
  end

  @spec handle_call(:result, any, internal_state) :: {:reply, any, internal_state}
  def handle_call(:result, _from, {:process, {handler, args}} = state) do
    case handler.run args do
      {:ok, _} = result -> {:reply, result, {:processed, result}}
      {:error, _} = err -> {:reply, err, state}
      otherwise -> {:reply, {:error, otherwise}, state}
    end
  end
  def handle_call(:result, _from, {:processed, result} = state) do
    {:reply, result, state}
  end
end
