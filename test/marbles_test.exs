defmodule MarblesTest do
  use ExUnit.Case, async: true
  doctest Marbles

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
      current: @initial_conditions
    }
  end

  test "update A" do
    Marbles.update(:box_A)
    assert Marbles.state == %State{
      previous: %{box_A: 11, box_B: 0},
      current: %{box_A: 10, box_B: 0}
    }
  end

  test "update B" do
    Marbles.update(:box_B)
    assert Marbles.state == %State{
      previous: %{box_A: 11, box_B: 0},
      current: %{box_A: 11, box_B: 1}
    }
  end

  test "ticks", _context do
    [head | _tail] = @partial_state_update_blocks
    variables = IO.inspect head[:variables]
    ticks = IO.inspect @simulation_parameters[:T]
    Enum.each(0..ticks, fn
      0 -> :nothing
      _ ->
        # state = IO.inspect Marbles.state
        variables |> Enum.each(fn x ->
          IO.inspect x
          Marbles.update(x)
        end)
        # :sys.replace_state(context[:pid], fn s -> %{s | state} end)
    end)
  end
end
