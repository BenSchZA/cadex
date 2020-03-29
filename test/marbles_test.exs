defmodule MarblesTest do
  use ExUnit.Case, async: true
  doctest Marbles

  alias :mnesia, as: Mnesia

  @initial_conditions %{
    box_A: 11,
    box_B: 0
  }

  @partial_state_update_blocks [
    %{
      policies: %{},
      variables: [
        :box_A,
        :box_B
      ]
    }
  ]

  @simulation_parameters %{
    T: 10,
    N: 1,
    M: %{},
  }

  setup_all do
    Mnesia.create_schema([node()])
    Mnesia.start()
    Mnesia.create_table(State, [attributes: [:id, :tick, :index, :current]])

    IO.inspect @partial_state_update_blocks
    :ok
  end

  setup do
    {:ok, pid} = Marbles.start_link(
      %State{
        previous: %{},
        current: @initial_conditions
      }
    )
    {:ok, %{pid: pid}}
  end

  test "initial state" do
    assert Marbles.state == %State{
      previous: %{},
      current: @initial_conditions,
      delta: %{}
    }
  end

  # test "update A" do
  #   Marbles.update(:box_A)
  #   assert Marbles.state = %State{
  #     previous: %{box_A: 11, box_B: 0},
  #     current: %{box_A: 10, box_B: 0},
  #     delta: _
  #   }
  # end

  # test "update B" do
  #   Marbles.update(:box_B)
  #   assert Marbles.state = %State{
  #     previous: %{box_A: 11, box_B: 0},
  #     current: %{box_A: 11, box_B: 1},
  #     delta: _
  #   }
  # end

  test "ticks", context do
    [head | _tail] = @partial_state_update_blocks
    variables = IO.inspect head[:variables]
    ticks = IO.inspect @simulation_parameters[:T]
    Enum.each(0..ticks, fn
      0 -> :nothing
      _ = tick ->
        variables
        |> Enum.with_index
        |> Enum.each(fn({var, index}) ->
          IO.inspect var
          Marbles.update(var)
          # state = %State{previous: _previous, current: _current} = Marbles.state
          # Marbles.update(var)
          # _state_ = %State{previous: _previous_, current: current_} = Marbles.state

          # Mnesia.dirty_write({
          #   State,
          #   Kernel.inspect(tick) <> Kernel.inspect(index),
          #   tick,
          #   index,
          #   current_
          # })
          # :sys.replace_state(context[:pid], fn _s -> state end)
        end)

        variables
        |> Enum.with_index
        |> Enum.each(fn({var, index}) ->
          state = %State{previous: _previous, current: current, delta: delta} = Marbles.state
          IO.inspect delta
          current_ = Map.update(current, var, nil, &(delta[var].(&1)))
          :sys.replace_state(context[:pid], &(Map.put(&1, :current, current_)))
        end)

        :sys.replace_state(context[:pid], &(Map.put(&1, :delta, %{})))

        # {result, states} = Mnesia.transaction(
        #   fn ->
        #     Mnesia.select(
        #       State,
        #       [{
        #         {State, :"$1", :"$2", :"$3", :"$4"},
        #         [{:==, :"$2", tick}],
        #         [:"$4"]
        #       }]
        #     )
        #   end
        # )
        # case result do
        #   :atomic ->
        #     :sys.replace_state(context[:pid], fn s -> {s | states} end)
        #   _ ->
        #     :nothing
        # end
        # data = variables
        # |> Enum.with_index
        # |> Enum.map(fn({_var, index}) ->
        #   Mnesia.transaction(fn -> Mnesia.match_object({State, tick, index, :_}) end)
        # end)
    end)
  end
end
