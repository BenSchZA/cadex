defmodule Cadex.Model do
  defmacro __using__(opts) do
    actions = opts[:actions] || []

    init =
      quote do
        use GenServer
        alias Cadex.Types
        import StructPipe

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

        def handle_call(:state, _from, %{current_state: current_state, impl: _impl}), do: {:reply, current_state, state}

        def handle_call({:set_current, value}, _from, state = %{current_state: current_state, impl: _impl}) do
          {:reply, Map.put(current_state, :current, value), state}
        end

        def handle_call(:reset_delta, _from, state = %{current_state: current_state, impl: _impl}) do
          {:reply, Map.put(current_state, :delta, %{}), state}
        end

        def handle_call({:update, var}, _from, state = %{current_state: %Cadex.Types.State{current: current, delta: delta} = current_state, impl: impl}) do
          {:ok, function} = impl.update(var, current_state)
          delta_ = %{var => function}
          current_state_ = current_state |> Map.put(:delta, Map.merge(delta, delta_))
          {:reply, current_state_, state}
        end

        def handle_call(:variables, _from, %{current_state: %Cadex.Types.State{current: current, delta: delta} = current_state, impl: _impl} = state) do
          # TODO: handle case when more than one PSUB
          %Cadex.Types.State{
            sim: %{
              partial_state_update_blocks: [
                %Cadex.Types.PartialStateUpdateBlock{variables: variables} | _tail
              ]
            }
          } = current_state

          {:reply, variables, state}
        end

        def handle_call(:policies, _from, %{current_state: %Cadex.Types.State{current: current, delta: delta} = current_state, impl: _impl} = state) do
          # TODO: handle case when more than one PSUB
          %Cadex.Types.State{
            sim: %{
              partial_state_update_blocks: [%Cadex.Types.PartialStateUpdateBlock{policies: policies} | _tail]
            }
          } = current_state

          {:reply, policies, state}
        end

        def handle_call(
              :apply,
              _from,
              %{current_state: %Cadex.Types.State{current: current, delta: delta} = current_state, impl: impl} = state
            ) do
          %Cadex.Types.State{
            sim: %{
              partial_state_update_blocks: [
                %Cadex.Types.PartialStateUpdateBlock{variables: variables} | _tail
              ]
            }
          } = current_state

          reduced =
            variables
            |> Enum.reduce(current, fn var, acc ->
              Map.update(acc, var, nil, &delta[var].(&1))
            end)

          {:reply, current_state,
           %{current_state: %Cadex.Types.State{state | previous: current} ~>> [current: reduced] ~>> [delta: %{}], impl: impl}}
        end

        # defoverridable init: 1
      end

    code =
      Enum.map(actions, fn action ->
        func_name = :"do_#{action}"

        quote do
          def unquote(action)(entity),
            do: GenServer.call(__MODULE__, {unquote(action), entity})

          def handle_call({unquote(action), _entity} = params, _from, state) do
            apply(__MODULE__, params)
            {:reply, :ok, state}
          end

          def handle_cast({unquote(action), _entity} = params, state) do
            apply(__MODULE__, params)
            {:noreply, state}
          end

          def unquote(func_name)(entity), do: entity
          defoverridable [{unquote(func_name), 1}]
        end
      end)

    [init | code]
  end
end
