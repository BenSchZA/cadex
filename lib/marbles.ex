defmodule State do
  defstruct previous: %{}, current: %{}, delta: %{}
end

defmodule Marbles do
  use GenServer

  @moduledoc """
  Documentation for Marbles.
  """

  ### GenServer API

  @doc """
  GenServer.init/1 callback
  """
  def init(state), do: {:ok, state}

  @doc """
  GenServer.child_spec/1 callback
  """
  def child_spec(opts) do
    %{
      id: Marbles,
      start: {__MODULE__, :start_link, [opts]},
      shutdown: 5_000,
      restart: :temporary,
      type: :worker
    }
  end

  @doc """
  GenServer.handle_call/3 callback
  """

  def handle_call(:state, _from, state), do: {:reply, state, state}

  @doc """
  GenServer.handle_cast/2 callback
  """

  def handle_cast(
        {:update, var},
        state = %State{previous: _previous, current: current, delta: delta}
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

    {
      :noreply,
      state
      |> Map.put(:delta, Map.merge(delta, delta_))
    }
  end

  def handle_cast(
        {:update, var},
        state = %State{previous: _previous, current: current, delta: delta}
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

    {
      :noreply,
      state
      |> Map.put(:delta, Map.merge(delta, delta_))
    }
  end

  ### Client API / Helper functions

  def start_link(state = %State{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def state, do: GenServer.call(__MODULE__, :state)
  def update(var), do: GenServer.cast(__MODULE__, {:update, var})
end
