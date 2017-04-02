defmodule EMage.Worker.Processor.State do
  @moduledoc """
  This module carries the state of a processor during its
  computational lifetime and can accumulate warnings when some occurs.
  """

  @type t :: %__MODULE__{
    token:      EMage.token,
    input:      EMage.url,
    stack:      EMage.operation_stack,
    output:     String.t,
    mime_type:  String.t,
    image:      Mogrify.t,
    warnings:   list(String.t)
  }

  defstruct [
    token:      nil,
    input:      nil,
    stack:      [],
    output:     nil,
    mime_type:  nil,
    image:      nil,
    warnings:   []
  ]

  @spec new(EMage.token, EMage.hash, String.t, EMage.operation_stack) :: State.t
  def new(token, hash, input, stack) do
    s = %__MODULE__{
      token: token,
      input: input,
      stack: stack,
      output: "/tmp/emage/#{hash}",
    } |> load(input)
  end

  @spec load(State.t, String.t) :: State.t
  def load(state, input) do
    image = input
      |> Mogrify.open
      |> Mogrify.verbose
    %{state | image: image}
  end
end
