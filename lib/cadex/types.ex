defmodule Cadex.Types do
  defmodule PartialStateUpdateBlock do
    defstruct policies: [], variables: []
  end

  defmodule SimulationParameters do
    defstruct T: 10, N: 1, M: %{}
  end

  defmodule State do
    # @enforce_keys [:sim, :current]
    defstruct sim: %{
                simulation_parameters: %SimulationParameters{},
                partial_state_update_blocks: [%PartialStateUpdateBlock{}]
              },
              previous_states: [],
              current_state: %{},
              delta: %{},
              signals: %{}
  end

  # defmodule StateUpdateParams do
  #   defstruct params: %{}, substep: -1, sH: [%State{}], s: %State{}, input: %{}
  # end

  # defmodule PolicyParams do
  #   defstruct params: %{}, substep: %{}, sH: [%State{}], s: %State{}
  # end
end
