defmodule Cadex.Behaviour do
  @callback config :: Cadex.Types.State.t()
  @callback update(var :: atom(), state :: Cadex.Types.State.t()) ::
              {:ok, (integer -> integer)} | {:error, String.t()}
end
