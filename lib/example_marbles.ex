defmodule Marbles do
  @behaviour Cadex.Behaviour

  @initial_conditions %{
    box_A: 11,
    box_B: 0
  }

  @partial_state_update_blocks [
    %Cadex.Types.PartialStateUpdateBlock{
      policies: [
        :robot_1,
        :robot_2
      ],
      variables: [
        :box_A,
        :box_B
      ]
    }
  ]

  @simulation_parameters %Cadex.Types.SimulationParameters{
    T: 10
  }

  @impl true
  def config do
    %Cadex.Types.State{
      sim: %{
        simulation_parameters: @simulation_parameters,
        partial_state_update_blocks: @partial_state_update_blocks
      },
      current_state: @initial_conditions
    }
  end

  @impl true
  def policy(_type, _params, _substep, _previous_states, _current_state) do
    {:ok, %{}}
  end

  @impl true
  def update(var = :box_A, _params, _substep, _previous_states, current_state, _input) do
    increment =
      &(&1 +
          cond do
            current_state[var] > current_state[:box_B] -> -1
            current_state[var] < current_state[:box_B] -> 1
            true -> 0
          end)

    {:ok, increment}
  end

  @impl true
  def update(var = :box_B, _params, _substep, _previous_states, current_state, _input) do
    increment =
      &(&1 +
          cond do
            current_state[var] > current_state[:box_A] -> -1
            current_state[var] < current_state[:box_A] -> 1
            true -> 0
          end)

    {:ok, increment}
  end
end
