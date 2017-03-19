defmodule EMage.Worker.Processor.State do
  @moduledoc """
  This module carries the state of a processor during its
  computational lifetime and can accumulate warnings when some occurs.
  """

  defstruct [
    input:      [],
    stack:      [],
    output:     nil,
    mime_type:  nil,
    image:      nil,
    warnings:   []
  ]

  def new(hash, input, stack) do
    %__MODULE__{
      input: input,
      stack: stack,
      output: "/tmp/emage/#{hash}",
      image: Mogrify.open(input)
    }
  end
end
