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
    M: %{}
  }

  setup_all do
    IO.inspect(@partial_state_update_blocks)
    :ok
  end

  setup do
    {:ok, pid} =
      Marbles.start_link(%State{
        current: @initial_conditions
      })

    {:ok, %{pid: pid}}
  end

  test "initial state" do
    state = Marbles.state()

    assert %State{
             previous: %{},
             current: @initial_conditions,
             delta: %{}
           } = state
  end

  test "update A" do
    Marbles.update(:box_A)
    state = Marbles.state()

    assert %State{
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
             previous: %{},
             current: %{box_A: 11, box_B: 0},
             delta: %{box_B: func}
           } = state

    assert Kernel.is_function(func)
  end

  test "apply delta", context do
    Marbles.update(:box_A)
    Marbles.update(:box_B)
    apply_delta(context[:pid], get_variables())

    assert %State{
             previous: %{box_A: 11, box_B: 0},
             current: %{box_A: 10, box_B: 1},
             delta: %{}
           } == Marbles.state()

    Marbles.update(:box_A)
    Marbles.update(:box_B)
    apply_delta(context[:pid], get_variables())

    assert %State{
             previous: %{box_A: 10, box_B: 1},
             current: %{box_A: 9, box_B: 2},
             delta: %{}
           } == Marbles.state()
  end

  def get_variables do
    [head | _tail] = @partial_state_update_blocks
    head[:variables]
  end

  def apply_delta(pid, variables) do
    %State{previous: _, current: current, delta: _} = Marbles.state()
    :sys.replace_state(pid, &Map.put(&1, :previous, current))

    variables
    |> Enum.each(fn var ->
      %State{previous: _, current: current, delta: delta} = Marbles.state()
      current_ = Map.update(current, var, nil, &delta[var].(&1))
      :sys.replace_state(pid, &Map.put(&1, :current, current_))
    end)

    :sys.replace_state(pid, &Map.put(&1, :delta, %{}))
  end

  test "ticks", context do
    variables = get_variables()

    Enum.each(0..@simulation_parameters[:T], fn
      0 ->
        :nothing

      _ = _tick ->
        Enum.each(variables, &Marbles.update(&1))

        apply_delta(context[:pid], variables)
    end)
  end
end
