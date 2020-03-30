defmodule Cadex do
  use GenServer
  import StructPipe

  @moduledoc """
  Documentation for Cadex.
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
      id: Cadex,
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

  def handle_call({:set_current, value}, _from, state) do
    {:reply, Map.put(state, :current, value), state}
  end

  def handle_call(:reset_delta, _from, state) do
    {:reply, Map.put(state, :delta, %{}), state}
  end

  def handle_call(:variables, _from, state) do
    # TODO: handle case when more than one PSUB
    %State{
      sim: %{
        partial_state_update_blocks: [%PartialStateUpdateBlock{variables: variables} | _tail]
      }
    } = state

    {:reply, variables, state}
  end

  def handle_call(:policies, _from, state) do
    # TODO: handle case when more than one PSUB
    %State{
      sim: %{
        partial_state_update_blocks: [%PartialStateUpdateBlock{policies: policies} | _tail]
      }
    } = state

    {:reply, policies, state}
  end

  def handle_call(
        :apply,
        _from,
        %State{current: current, delta: delta} = state
      ) do
    %State{
      sim: %{
        partial_state_update_blocks: [%PartialStateUpdateBlock{variables: variables} | _tail]
      }
    } = state

    reduced =
      variables
      |> Enum.reduce(current, fn var, acc ->
        Map.update(acc, var, nil, &delta[var].(&1))
      end)

    {:reply, state, %State{state | previous: current} ~>> [current: reduced] ~>> [delta: %{}]}
  end

  @doc """
  GenServer.handle_cast/2 callback
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

  ### Client API / Helper functions

  def start_link(state = %State{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def state, do: GenServer.call(__MODULE__, :state)
  def variables, do: GenServer.call(__MODULE__, :variables)
  def policies, do: GenServer.call(__MODULE__, :policies)
  def apply, do: GenServer.call(__MODULE__, :apply)

  def set_current(value), do: GenServer.call(__MODULE__, {:set_current, value})
  def reset_delta, do: GenServer.call(__MODULE__, :reset_delta)

  def update(var), do: GenServer.call(__MODULE__, {:update, var})
end
