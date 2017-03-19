defmodule EMage.Worker.Processor do
  @moduledoc """
  """

  import Mogrify
  alias EMage.Future
  alias EMage.Worker.{Downloader, Processor.State}

  @operation_methods %{
    "siz" => "resize",
    "rot" => "rotate",
    "rbl" => "radial-blur",
    "ras" => "raise"
  }
  @operation_codes Map.keys @operation_methods

  @behaviour EMage.Future.Handler

  @type t :: pid
  @type stack :: list(String.t)

  @spec by(EMage.token, Downloader.t, EMage.url, stack) :: Processor.t
  def by(token, downloader, url, stack) do
    sup = {:via, Registry, {EMage.Registry.Tokens, {token, :processors}}}
    {:ok, pid} = Supervisor.start_child sup, [token, downloader, url, stack]
    pid
  end

  def start_link(token, downloader, url, stack) do
    hash = [url] ++ stack
      |> Enum.join(" ")
      |> EMage.hash
    name = {:via, Registry, {:"EMage.Registry.Processors.#{token}", hash}}
    args = {hash, downloader, stack}
    case Future.start_link __MODULE__, args, name: name do
      {:ok, _} = res -> res
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  def run({hash, downloader, stack}) do
    with {:ok, input} <- Future.result(downloader),
         {:ok, state} <- make_state(hash, input, stack) do
         process(state)
    else
      otherwise -> otherwise
    end
  end

  def make_state(hash, input, stack) do
    {:ok, State.new(hash, input, stack)}
  end

  # Process the next operation based on its code and params.
  def process(%State{stack: [<<c::bytes-size(3), "_", p::binary>> | r]} = s) do
    %{s | stack: r}
      |> operation(c, p)
      |> process
  end
  # Once we reach the end of the chain, save the image and return a success.
  def process(%State{image: image, output: output} = s) do
    IO.puts "~> End of chain reached."
    {:ok, %{s | image: save(image, path: output)}}
  end

  # Format operations are special, as they change the state.
  def operation(%State{image: image} = state, "fmt", fmt) do
    IO.puts "~> Formatting into #{fmt}."
    %{state | image: format(image, fmt), mime_type: "image/#{fmt}"}
  end
  def operation(%State{image: image} = state, code, params) when code in @operation_codes do
    IO.puts "~> Operation #{code}."
    %{state | image: custom(image, @operation_methods[code], params)}
  end
  # Unknown operation, just add a warning.
  def operation(%State{warnings: warnings} = state, code, _) do
    %{state | warnings: ["Unknown operation #{code}."] ++ warnings}
  end

end
