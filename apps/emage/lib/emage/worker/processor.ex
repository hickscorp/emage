defmodule EMage.Worker.Processor do
  @moduledoc """
  """

  alias EMage.Future
  alias EMage.Worker.{Downloader, Processor.State}

  @operation_methods %{
    "lbl" => "label",
    "dep" => "depth",
    "siz" => "resize",
    "crp" => "crop",
    "rot" => "rotate",
    "rbl" => "radial-blur",
    "ras" => "raise",
    "gra" => "gravity",
    "geo" => "geometry"
  }
  @operation_codes Map.keys @operation_methods

  @behaviour EMage.Future.Handler

  @type t :: pid
  @type stack :: list(String.t)

  @spec by(EMage.token, Downloader.t, EMage.url, EMage.operations) :: t
  def by(token, downloader, url, stack) do
    sup = {:via, Registry, {EMage.Registry.Tokens, {token, :processors}}}
    {:ok, pid} = Supervisor.start_child sup, [token, downloader, url, stack]
    pid
  end

  @spec start_link(EMage.token, Downloader.t, EMage.url, EMage.operations) :: {:ok, t}
  def start_link(token, downloader, url, stack) do
    hash = [url] ++ stack
      |> Enum.join(" ")
      |> EMage.hash
    name = {:via, Registry, {:"EMage.Registry.Processors.#{token}", hash}}
    args = {token, hash, downloader, stack}
    case Future.start_link __MODULE__, args, name: name do
      {:ok, _} = res -> res
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  @spec run({EMage.token, EMage.hash, Downloader.t, EMage.operations}) :: {:ok, State.t} | {:error, {atom(), String.t}}
  def run({token, hash, downloader, stack}) do
    with {:ok, input} <- Future.result(downloader),
         %State{} = state <- make_state(token, hash, input, stack) do
         process(state)
    else
      otherwise -> otherwise
    end
  end

  @spec make_state(EMage.token, EMage.hash, EMage.url, EMage.operations) :: State.t
  def make_state(token, hash, input, stack) do
    State.new(token, hash, input, stack)
  end

  # Process the next operation based on its code and params.
  @spec process(State.t) :: {:ok, State.t}
  def process(%{stack: [<<code::bytes-size(3), "_", params::binary>> | rest]} = state) do
    %{state | stack: rest}
      |> operation(code, params)
      |> process
  end
  # Once we reach the end of the chain, save the image and return a success.
  def process(%{image: image, output: output} = s) do
    IO.puts "~> End of chain reached."
    {:ok, %{s | image: Mogrify.save(image, path: output),
                mime_type: "image/#{image.format}"}}
  end

  # Format operations are special, as they change the state.
  @spec operation(State.t, EMage.op_code, EMage.op_params) :: State.t
  def operation(%{image: image} = state, "fmt", fmt) do
    IO.puts "~> Formatting into #{fmt}."
    %{state | image: Mogrify.format(image, fmt)}
  end
  def operation(%{token: token, image: image} = state, "wtk", params) do
    IO.puts "-> Watermarking #{params}"
    [origin, size, source] = String.split params, " "
    filename = Downloader.result_by token, source
    IO.puts "-> Downloaded source image into #{filename}."
    image = Mogrify.custom(image, "draw", "image Over #{origin} #{size} \"#{filename}\"")

    %{state | image: image}
  end
  def operation(%{image: image} = state, code, params) when code in @operation_codes do
    IO.puts "~> Operation #{code}: #{params}."
    %{state | image: Mogrify.custom(image, @operation_methods[code], params)}
  end
  # Unknown operation, just add a warning.
  def operation(%State{warnings: warnings} = state, code, _) do
    %{state | warnings: ["Unknown operation #{code}."] ++ warnings}
  end
end
