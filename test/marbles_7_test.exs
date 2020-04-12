defmodule Marbles7Test do
  use ExUnit.Case, async: false
  doctest Marbles7
  import Cadex.Types
  alias Cadex.Types
  alias Marbles7

  @initial_conditions %{
    box_A: 10,
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
    T: 50
  }

  setup_all do
    IO.inspect(@partial_state_update_blocks)
    :ok
  end

  setup do
    {:ok, pid} = Cadex.start(Marbles7)
    {:ok, %{pid: pid}}
  end

  test "cadex run" do
    assert {:ok, %Cadex.Types.State{} = state} = Cadex.run()
    IO.inspect state
  end
end
