defmodule Marbles7 do
  @behaviour Cadex.Behaviour

  @initial_conditions %{
    box_A: 10,
    box_B: 0
  }

  @partial_state_update_blocks [
    %Cadex.Types.PartialStateUpdateBlock{
      policies: [
        :robot_1,
        :robot_2
      ],
      variables: [
        {:box_A, :a},
        :box_B
      ]
    }
  ]

  @simulation_parameters %Cadex.Types.SimulationParameters{
    T: 0..30,
    N: 50
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

  @robots_probabilities [0.5, 1/3]
  def policy_helper(_params, _substep, _previous_states, current_state, capacity \\ 1) do
    add_to_A = cond do
      current_state[:box_A] > current_state[:box_B] -> -capacity
      current_state[:box_A] < current_state[:box_B] -> capacity
      true -> 0
    end
    {:ok, %{add_to_A: add_to_A, add_to_B: -add_to_A}}
  end

  @impl true
  def policy(:robot_1, params, substep, previous_states, current_state) do
    robot_ID = 1
    cond do
      :rand.uniform < @robots_probabilities |> Enum.at(robot_ID - 1) ->
        policy_helper(params, substep, previous_states, current_state)
      true -> {:ok, %{add_to_A: 0, add_to_B: 0}}
    end
  end

  @impl true
  def policy(:robot_2, params, substep, previous_states, current_state) do
    robot_ID = 2
    cond do
      :rand.uniform < @robots_probabilities |> Enum.at(robot_ID - 1) ->
        policy_helper(params, substep, previous_states, current_state)
      true -> {:ok, %{add_to_A: 0, add_to_B: 0}}
    end
  end

  @impl true
  def update(_var = {:box_A, :a}, _params, _substep, _previous_states, _current_state, input) do
    %{add_to_A: add_to_A} = input
    increment = &(&1 + add_to_A)

    {:ok, increment}
  end

  @impl true
  def update(_var = :box_B, _params, _substep, _previous_states, _current_state, input) do
    %{add_to_B: add_to_B} = input
    increment = &(&1 + add_to_B)

    {:ok, increment}
  end
end
