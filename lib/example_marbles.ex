defmodule Marbles do
  use Cadex
  import StructPipe

  @moduledoc """
  Documentation for Marbles Cadex example.
  """

  ### Cadex state update functions

  @doc """
  GenServer.handle_call/3 callback
  """

  def handle_call(
        {:update, var},
        _from,
        state = %State{current: current, delta: delta}
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
        state = %State{current: current, delta: delta}
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
