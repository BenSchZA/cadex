defmodule Cadex.Behaviour do
  @callback config :: %Cadex.Types.State{}
  @callback policy(
              type :: atom(),
              params :: %{optional(atom()) => any()},
              substep :: integer,
              previous_states :: %{optional(atom()) => any()},
              current_state :: %{optional(atom()) => any()}
            ) ::
              {:ok, %{optional(atom()) => any()}} | {:error, String.t()}
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
