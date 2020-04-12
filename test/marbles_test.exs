defmodule MarblesTest do
  use ExUnit.Case, async: false
  doctest Marbles
  import Cadex.Types
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
    T: 0..10
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
             delta: %{},
             signals: %{}
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
    debug = true
    assert {:ok, results} = Cadex.run(debug)
  end

  test "pyplot" do
    {:ok, results} = Cadex.run()
    %{run: _run, result: run_results} = results |> List.first
    box_A_plot = run_results |> Enum.map(fn result ->
      %{timestep: _timestep, state: state} = result |> List.last
      %{box_A: box_A} = state |> List.last
      box_A
    end)

    box_B_plot = run_results |> Enum.map(fn result ->
      %{timestep: _timestep, state: state} = result |> List.last
      %{box_B: box_B} = state |> List.last
      box_B
    end)

    PythonInterface.plot(box_A_plot, box_B_plot)
  end
end
