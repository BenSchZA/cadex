defmodule Cadex.Behaviour do
  @callback config :: Cadex.Types.State.t()
  # @callback policy()
  @callback update(
              var :: atom(),
              params :: %{optional(atom()) => any()},
              substep :: integer,
              previous_states :: %{optional(atom()) => any()},
              current_state :: %{optional(atom()) => any()},
              input :: %{optional(atom()) => any()}
            ) ::
              {:ok, (any() -> any())} | {:error, String.t()}
end
