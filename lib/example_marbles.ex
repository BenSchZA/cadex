defmodule Marbles do
  alias Cadex.Types
  use Cadex.Model

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

  def start do
    {:ok, pid} = Marbles.start_link(%Cadex.Types.State{
      sim: %{
        simulation_parameters: @simulation_parameters,
        partial_state_update_blocks: @partial_state_update_blocks
      },
      current: @initial_conditions
    })
    {:ok, pid}
  end

  @moduledoc """
  Documentation for Marbles Cadex example.
  """

  ### Marbles state update functions

  @doc """
  GenServer.handle_call/3 callback
  """

  def handle_call(
        {:update, var},
        _from,
        state = %Cadex.Types.State{current: current, delta: delta}
      )
      when var == :box_A do
    increment =
      &(&1 +
          cond do
            current[var] > current[:box_B] -> -1
            current[var] < current[:box_B] -> 1
            true -> 0
          end)

    delta_ = %{var => increment}

    state_ =
      state
      |> Map.put(:delta, Map.merge(delta, delta_))

    {
      :reply,
      state_,
      state_
    }
  end

  def handle_call(
        {:update, var},
        _from,
        state = %Cadex.Types.State{current: current, delta: delta}
      )
      when var == :box_B do
    increment =
      &(&1 +
          cond do
            current[var] > current[:box_A] -> -1
            current[var] < current[:box_A] -> 1
            true -> 0
          end)

    delta_ = %{var => increment}

    state_ =
      state
      |> Map.put(:delta, Map.merge(delta, delta_))

    {
      :reply,
      state_,
      state_
    }
  end
end
