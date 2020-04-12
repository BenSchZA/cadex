defmodule Cadex do
  use GenServer
  alias Cadex.Types
  import StructPipe
  require Logger

  @spec start(any, nil | %Cadex.Types.State{}) :: {:ok, any}
  def start(impl, override \\ nil) do
    initial_state =
      case override do
        nil -> impl.config()
        %Cadex.Types.State{} -> override
      end

    {:ok, pid} = start_link(%{model_state: initial_state, impl: impl})
    {:ok, pid}
  end

  def start_link(state), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)
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

  def handle_call(:state, _from, %{model_state: model_state, impl: _impl} = state),
    do: {:reply, model_state, state}

  def handle_call(
        {:set_current, value},
        _from,
        state = %{model_state: model_state, impl: _impl}
      ) do
    {:reply, Map.put(model_state, :current, value), state}
  end

  def handle_call(:reset_delta, _from, state = %{model_state: model_state, impl: _impl}) do
    {:reply, Map.put(model_state, :delta, %{}), state}
  end

  def handle_call(
        {:update, var},
        _from,
        state =
          %{
            model_state: %Cadex.Types.State{previous_states: previous_states, current_state: current_state, delta: delta} = model_state,
            impl: impl
          } = state
      ) do
    Logger.info("Calculating state variable update for #{var}")
    {:ok, function} = impl.update(var, %{}, -1, previous_states, current_state, %{})
    delta_ = %{var => function}
    model_state_ = model_state |> Map.put(:delta, Map.merge(delta, delta_))
    {:reply, model_state_, %{state | model_state: model_state_}}
  end

  def handle_call(:variables, _from, state = %{model_state: model_state, impl: _impl}) do
    # TODO: handle case when more than one PSUB
    %Cadex.Types.State{
      sim: %{
        partial_state_update_blocks: [
          %Cadex.Types.PartialStateUpdateBlock{variables: variables} | _tail
        ]
      }
    } = model_state

    {:reply, variables, state}
  end

  def handle_call(:policies, _from, state = %{model_state: model_state, impl: _impl}) do
    # TODO: handle case when more than one PSUB
    %Cadex.Types.State{
      sim: %{
        partial_state_update_blocks: [
          %Cadex.Types.PartialStateUpdateBlock{policies: policies} | _tail
        ]
      }
    } = model_state

    {:reply, policies, state}
  end

  def handle_call(
        :apply,
        _from,
        %{
          model_state: %Cadex.Types.State{previous_states: previous_states, current_state: current_state, delta: delta} = model_state,
          impl: impl
        }
      ) do
    Logger.info("Applying state updates")
    %Cadex.Types.State{
      sim: %{
        partial_state_update_blocks: [
          %Cadex.Types.PartialStateUpdateBlock{variables: variables} | _tail
        ]
      }
    } = model_state

    reduced =
      variables
      |> Enum.reduce(current_state, fn var, acc ->
        Map.update(acc, var, nil, &delta[var].(&1))
      end)

    {:reply, model_state,
     %{
      model_state:
         %Cadex.Types.State{model_state | previous_states: previous_states ++ [current_state]}
         ~>> [current_state: reduced]
         ~>> [delta: %{}],
       impl: impl
     }}
  end

  @spec state :: any
  def state, do: GenServer.call(__MODULE__, :state)
  @spec update(any) :: any
  def update(var), do: GenServer.call(__MODULE__, {:update, var})
  @spec variables :: any
  def variables, do: GenServer.call(__MODULE__, :variables)
  @spec policies :: any
  def policies, do: GenServer.call(__MODULE__, :policies)
  @spec apply :: any
  def apply, do: GenServer.call(__MODULE__, :apply)
  @spec set_current(any) :: any
  def set_current(value), do: GenServer.call(__MODULE__, {:set_current, value})
  @spec reset_delta :: any
  def reset_delta, do: GenServer.call(__MODULE__, :reset_delta)
end
