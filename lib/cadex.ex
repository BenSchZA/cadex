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

  def run(debug \\ false) do
    %Cadex.Types.State{
      sim: %{
        simulation_parameters: %Cadex.Types.SimulationParameters{N: runs, T: range},
        partial_state_update_blocks: partial_state_update_blocks
      }
    } = state()

    case debug do
      true -> Logger.configure(level: :debug)
      false -> Logger.configure(level: :info)
    end

    results =
      Enum.map(1..runs, fn run ->
        result =
          Enum.map(range, fn
            0 ->
              nil

            _ = timestep ->
              partial_state_update_blocks
              |> Enum.with_index()
              |> Enum.map(fn {%Cadex.Types.PartialStateUpdateBlock{
                                policies: policies,
                                variables: variables
                              }, substep} ->
                policies |> Enum.each(&policy(&1, substep))
                variables |> Enum.each(&update(&1, substep))
                %Cadex.Types.State{previous_states: previous_states} = apply()
                %{timestep: timestep, substep: substep, state: previous_states}
              end)
          end)

        %{run: run, result: result |> Enum.filter(fn x -> !is_nil(x) end)}
      end)

    {:ok, results}
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
        {:policy, type, substep},
        _from,
        state = %{
          model_state:
            %Cadex.Types.State{
              previous_states: previous_states,
              current_state: current_state,
              delta: _delta,
              signals: signals
            } = model_state,
          impl: impl
        }
      ) do
    Logger.debug("Applying policy #{type}")
    {:ok, signals_} = impl.policy(type, %{}, substep, previous_states, current_state)
    model_state_ = model_state |> Map.put(:signals, Map.merge(signals, signals_))
    {:reply, model_state_, %{state | model_state: model_state_}}
  end

  def handle_call(
        {:update, var, substep},
        _from,
        state = %{
          model_state:
            %Cadex.Types.State{
              previous_states: previous_states,
              current_state: current_state,
              delta: delta,
              signals: signals
            } = model_state,
          impl: impl
        }
      ) do
    Logger.debug("Calculating state variable update for #{var}")
    {:ok, function} = impl.update(var, %{}, substep, previous_states, current_state, signals)
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
          model_state:
            %Cadex.Types.State{
              previous_states: previous_states,
              current_state: current_state,
              delta: delta
            } = model_state,
          impl: impl
        }
      ) do
    Logger.debug("Applying state updates")

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

    model_state_ =
      %Cadex.Types.State{model_state | previous_states: previous_states ++ [current_state]}
      ~>> [current_state: reduced]
      ~>> [delta: %{}]
      ~>> [signals: %{}]

    {:reply, model_state_,
     %{
       model_state: model_state_,
       impl: impl
     }}
  end

  @spec state :: any
  def state, do: GenServer.call(__MODULE__, :state)
  @spec policy(any, any) :: any
  def policy(type, substep \\ 0), do: GenServer.call(__MODULE__, {:policy, type, substep})
  @spec update(any, any) :: any
  def update(var, substep \\ 0), do: GenServer.call(__MODULE__, {:update, var, substep})
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
