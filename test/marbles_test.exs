defmodule MarblesTest do
  use ExUnit.Case, async: true
  doctest Marbles
  import Cadex.Types
  alias Cadex.Types
  alias Marbles

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

  setup_all do
    IO.inspect(@partial_state_update_blocks)
    :ok
  end

  setup do
    {:ok, pid} = Cadex.start(Marbles)
    {:ok, %{pid: pid}}
  end

  test "initial state" do
    state = Cadex.state()

    assert %Cadex.Types.State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous_states: [],
             current_state: @initial_conditions,
             delta: %{}
           } = state
  end

  test "update A" do
    Cadex.update(:box_A)
    state = Cadex.state()

    assert %Cadex.Types.State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous_states: [],
             current_state: %{box_A: 11, box_B: 0},
             delta: %{box_A: func}
           } = state

    assert Kernel.is_function(func)
  end

  test "update B" do
    Cadex.update(:box_B)
    state = Cadex.state()

    assert %Cadex.Types.State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous_states: [],
             current_state: %{box_A: 11, box_B: 0},
             delta: %{box_B: func}
           } = state

    assert Kernel.is_function(func)
  end

  test "apply delta" do
    Cadex.update(:box_A)
    Cadex.update(:box_B)
    Cadex.apply()

    assert %Cadex.Types.State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous_states: [%{box_A: 11, box_B: 0}],
             current_state: %{box_A: 10, box_B: 1},
             delta: %{}
           } == Cadex.state()

    Cadex.update(:box_A)
    Cadex.update(:box_B)
    Cadex.apply()

    assert %Cadex.Types.State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous_states: [%{box_A: 11, box_B: 0}, %{box_A: 10, box_B: 1}],
             current_state: %{box_A: 9, box_B: 2},
             delta: %{}
           } == Cadex.state()
  end

  test "call variables" do
    assert [
      :box_A,
      :box_B
    ] == Cadex.variables()
  end

  test "call policies" do
    assert [
      :robot_1,
      :robot_2
    ] == Cadex.policies()
  end

  test "reset delta" do
    %Cadex.Types.State{delta: delta} = Cadex.state()
    assert delta == %{}
    Cadex.update(:box_A)
    %Cadex.Types.State{delta: delta} =  Cadex.update(:box_B)
    assert delta !== %{}
    %Cadex.Types.State{delta: delta} = Cadex.reset_delta()
    assert delta == %{}
  end

  test "cadex run" do
    assert {:ok, %Cadex.Types.State{} = state} = Cadex.run()
    IO.inspect state
  end
end
