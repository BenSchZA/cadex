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
      current: @initial_conditions
    }
  end

  @impl true
  def update(var = :box_A, _state = %Cadex.Types.State{current: current}) do
    increment =
      &(&1 +
          cond do
            current[var] > current[:box_B] -> -1
            current[var] < current[:box_B] -> 1
            true -> 0
          end)

    {:ok, increment}
  end

  @impl true
  def update(var = :box_B, _state = %Cadex.Types.State{current: current}) do
    increment =
      &(&1 +
          cond do
            current[var] > current[:box_A] -> -1
            current[var] < current[:box_A] -> 1
            true -> 0
          end)

    {:ok, increment}
  end
end
