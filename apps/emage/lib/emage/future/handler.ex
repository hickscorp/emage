defmodule EMage.Future.Handler do
  @moduledoc """
  """
  @callback run(any) :: {:ok | :error, any}
end
