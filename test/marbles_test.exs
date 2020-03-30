defmodule MarblesTest do
  use ExUnit.Case, async: true
  doctest Cadex

  @initial_conditions %{
    box_A: 11,
    box_B: 0
  }

  @partial_state_update_blocks [
    %PartialStateUpdateBlock{
      policies: [],
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
      Cadex.start_link(%State{
        sim: %{
          simulation_parameters: @simulation_parameters,
          partial_state_update_blocks: @partial_state_update_blocks
        },
        current: @initial_conditions
      })

    {:ok, %{pid: pid}}
  end

  test "initial state" do
    state = Cadex.state()

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
    Cadex.update(:box_A)
    state = Cadex.state()

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
    Cadex.update(:box_B)
    state = Cadex.state()

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
    Cadex.update(:box_A)
    Cadex.update(:box_B)
    Cadex.apply()

    assert %State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous: %{box_A: 11, box_B: 0},
             current: %{box_A: 10, box_B: 1},
             delta: %{}
           } == Cadex.state()

    Cadex.update(:box_A)
    Cadex.update(:box_B)
    Cadex.apply()

    assert %State{
             sim: %{
               simulation_parameters: @simulation_parameters,
               partial_state_update_blocks: @partial_state_update_blocks
             },
             previous: %{box_A: 10, box_B: 1},
             current: %{box_A: 9, box_B: 2},
             delta: %{}
           } == Cadex.state()
  end

  test "ticks" do
    variables = Cadex.variables()
    %SimulationParameters{T: ticks} = @simulation_parameters

    Enum.each(0..ticks, fn
      0 ->
        :nothing

      _ = _tick ->
        variables
        |> Enum.each(&Cadex.update(&1))

        IO.inspect(Cadex.state())
        Cadex.apply()
    end)
  end
end
