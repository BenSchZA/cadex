defmodule MarblesTest do
  use ExUnit.Case, async: true
  doctest Marbles

  @initial_conditions %{
    box_A: 11,
    box_B: 0
  }

  @partial_state_update_blocks [
    %PartialStateUpdateBlock{
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

  @simulation_parameters %SimulationParameters{
    T: 10
  }

  setup_all do
    IO.inspect(@partial_state_update_blocks)
    :ok
  end

  setup do
    {:ok, pid} =
      Marbles.start_link(%State{
        sim: %{
          simulation_parameters: @simulation_parameters,
          partial_state_update_blocks: @partial_state_update_blocks
        },
        current: @initial_conditions
      })

    {:ok, %{pid: pid}}
  end

  test "initial state" do
    state = Marbles.state()

    assert %State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous: %{},
             current: @initial_conditions,
             delta: %{}
           } = state
  end

  test "update A" do
    Marbles.update(:box_A)
    state = Marbles.state()

    assert %State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous: %{},
             current: %{box_A: 11, box_B: 0},
             delta: %{box_A: func}
           } = state

    assert Kernel.is_function(func)
  end

  test "update B" do
    Marbles.update(:box_B)
    state = Marbles.state()

    assert %State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous: %{},
             current: %{box_A: 11, box_B: 0},
             delta: %{box_B: func}
           } = state

    assert Kernel.is_function(func)
  end

  test "apply delta" do
    Marbles.update(:box_A)
    Marbles.update(:box_B)
    Marbles.apply()

    assert %State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous: %{box_A: 11, box_B: 0},
             current: %{box_A: 10, box_B: 1},
             delta: %{}
           } == Marbles.state()

    Marbles.update(:box_A)
    Marbles.update(:box_B)
    Marbles.apply()

    assert %State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous: %{box_A: 10, box_B: 1},
             current: %{box_A: 9, box_B: 2},
             delta: %{}
           } == Marbles.state()
  end

  test "call variables" do
    assert [
      :box_A,
      :box_B
    ] == Marbles.variables()
  end

  test "call policies" do
    assert [
      :robot_1,
      :robot_2
    ] == Marbles.policies()
  end

  test "reset delta" do
    %State{delta: delta} = Marbles.state()
    assert delta == %{}
    Marbles.update(:box_A)
    %State{delta: delta} =  Marbles.update(:box_B)
    assert delta !== %{}
    %State{delta: delta} = Marbles.reset_delta()
    assert delta == %{}
  end

  test "ticks" do
    variables = Marbles.variables()
    %SimulationParameters{T: ticks} = @simulation_parameters

    Enum.each(0..ticks, fn
      0 ->
        :nothing

      _ = _tick ->
        variables
        |> Enum.each(&Marbles.update(&1))

        IO.inspect(Marbles.state())
        Marbles.apply()
    end)
  end
end
