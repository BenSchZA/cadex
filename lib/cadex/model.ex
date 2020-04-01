defmodule Cadex.Model do
  # defmacro __before_compile__(_) do
  #   quote do
  #     def handle_call(msg, from, state) do
  #       IO.inspect {:unknown_message, msg}
  #       {:reply, state, state}
  #     end
  #  end
  # end

  defmacro __using__(opts) do
    actions = opts[:actions] || []

    init =
      quote do
        use GenServer
        alias Cadex.Types
        import StructPipe

        # defmodule State do
        #   # @enforce_keys [:sim, :current]
        #   defstruct sim: unquote(Macro.escape(Keyword.get(opts, :sim, %{}))),
        #             current: unquote(Macro.escape(Keyword.get(opts, :initial_conditions, %{}))),
        #             previous: %{},
        #             delta: %{}
        # end

        def start_link(state \\ %Cadex.Types.State{}),
          do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

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
          %Cadex.Types.State{
            sim: %{
              partial_state_update_blocks: [
                %Cadex.Types.PartialStateUpdateBlock{variables: variables} | _tail
              ]
            }
          } = state

          {:reply, variables, state}
        end

        def handle_call(:policies, _from, state) do
          # TODO: handle case when more than one PSUB
          %Cadex.Types.State{
            sim: %{
              partial_state_update_blocks: [%Cadex.Types.PartialStateUpdateBlock{policies: policies} | _tail]
            }
          } = state

          {:reply, policies, state}
        end

        def handle_call(
              :apply,
              _from,
              %Cadex.Types.State{current: current, delta: delta} = state
            ) do
          %Cadex.Types.State{
            sim: %{
              partial_state_update_blocks: [
                %Cadex.Types.PartialStateUpdateBlock{variables: variables} | _tail
              ]
            }
          } = state

          reduced =
            variables
            |> Enum.reduce(current, fn var, acc ->
              Map.update(acc, var, nil, &delta[var].(&1))
            end)

          {:reply, state,
           %Cadex.Types.State{state | previous: current} ~>> [current: reduced] ~>> [delta: %{}]}
        end

        ### Client API / Helper functions
        def state, do: GenServer.call(__MODULE__, :state)
        def update(var), do: GenServer.call(__MODULE__, {:update, var})
        def variables, do: GenServer.call(__MODULE__, :variables)
        def policies, do: GenServer.call(__MODULE__, :policies)
        def apply, do: GenServer.call(__MODULE__, :apply)
        def set_current(value), do: GenServer.call(__MODULE__, {:set_current, value})
        def reset_delta, do: GenServer.call(__MODULE__, :reset_delta)

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
