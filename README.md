# Cadex

An Elixir GenServer module based on the popular Python package [cadCAD](https://cadcad.org): "Design, test and validate complex systems through simulation in Python".

This is an exercise in better understanding system modelling, simulation, complex systems, and the design of cadCAD. 

It also serves as a learning exercise in the Erlang/Elixir OTP actor model and GenServer based programming constructs! In fact, it is the OTP actor model that originally made me think of the similarities to graph theory and the way state is managed in complex system modelling.

Designing a differential games engine also uses all the best features of the Elixir language: it is functional, expressive, has great data constructs, pattern matching, scalability, it enables creating maintainable code, and has incredible tooling.

## Basic Usage

Example robots & marbles model:

```elixir
defmodule Marbles7 do
  @behaviour Cadex.Behaviour

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
    T: 50,
    N: 30
  }

  @impl true
  def config do
    %Cadex.Types.State{
      sim: %{
        simulation_parameters: @simulation_parameters,
        partial_state_update_blocks: @partial_state_update_blocks
      },
      current_state: @initial_conditions
    }
  end

  @robots_probabilities [0.5, 1/3]
  def policy_helper(_params, _substep, _previous_states, current_state, capacity \\ 1) do
    add_to_A = cond do
      current_state[:box_A] > current_state[:box_B] -> -capacity
      current_state[:box_A] < current_state[:box_B] -> capacity
      true -> 0
    end
    {:ok, %{add_to_A: add_to_A, add_to_B: -add_to_A}}
  end

  @impl true
  def policy(:robot_1, params, substep, previous_states, current_state) do
    robot_ID = 1
    cond do
      :rand.uniform < @robots_probabilities |> Enum.at(robot_ID - 1) ->
        policy_helper(params, substep, previous_states, current_state)
      true -> {:ok, %{add_to_A: 0, add_to_B: 0}}
    end
  end

  @impl true
  def policy(:robot_2, params, substep, previous_states, current_state) do
    robot_ID = 2
    cond do
      :rand.uniform < @robots_probabilities |> Enum.at(robot_ID - 1) ->
        policy_helper(params, substep, previous_states, current_state)
      true -> {:ok, %{add_to_A: 0, add_to_B: 0}}
    end
  end

  @impl true
  def update(_var = :box_A, _params, _substep, _previous_states, _current_state, input) do
    %{add_to_A: add_to_A} = input
    increment = &(&1 + add_to_A)

    {:ok, increment}
  end

  @impl true
  def update(_var = :box_B, _params, _substep, _previous_states, _current_state, input) do
    %{add_to_B: add_to_B} = input
    increment = &(&1 + add_to_B)

    {:ok, increment}
  end
end
```

Running the simulation:

```elixir
{:ok, _pid} = Cadex.start(Marbles7)
{:ok, %Cadex.Types.State{} = state} = Cadex.run()
```

Generate plot via `export`:

```elixir
{:ok, runs} = Cadex.run(debug=false)

box_A_plots = runs |> Enum.map(fn %{run: _run, result: result} ->
  result |> Enum.map(fn timestep ->
    %{state: state} = timestep |> List.last
    %{box_A: box_A} = state |> List.last
    box_A
  end)
end)

box_B_plots = runs |> Enum.map(fn %{run: _run, result: result} ->
  result |> Enum.map(fn timestep ->
    %{state: state} = timestep |> List.last
    %{box_B: box_B} = state |> List.last
    box_B
  end)
end)

PythonInterface.plot_marble_runs(box_A_plots, box_B_plots)
```

![Robots and marbles plot](https://github.com/BenSchZA/cadex/raw/master/media/robots_and_marbles_plot.png)

## Development

I've created a [Nix](https://nixos.org/nix/) shell for development, `shell.nix`. This includes all the dependencies you should need, and should work on both Linux and Mac - I've only tested it on Linux.

1. Install Nix: `curl -L --proto '=https' --tlsv1.2 https://nixos.org/nix/install | sh`
2. Enter Nix shell: `nix-shell`

## Testing

The test `test/marbles_test.exs` provides a good example of a basic model, the cadCAD robots and marbles model.

To run this test, enter the development environment, and run `mix test test/marbles_test.exs`.

You should see output as follows:

```elixir
[%PartialStateUpdateBlock{policies: [], variables: [:box_A, :box_B]}]
.%State{
  current: %{box_A: 11, box_B: 0},
  delta: %{
    box_A: #Function<2.72390911/1 in Cadex.handle_cast/2>,
    box_B: #Function<1.72390911/1 in Cadex.handle_cast/2>
  },
  previous: %{},
  sim: %{
    partial_state_update_blocks: [
      %PartialStateUpdateBlock{policies: [], variables: [:box_A, :box_B]}
    ],
    simulation_parameters: %SimulationParameters{M: %{}, N: 1, T: 10}
  }
}
%State{
  current: %{box_A: 10, box_B: 1},
  delta: %{
    box_A: #Function<2.72390911/1 in Cadex.handle_cast/2>,
    box_B: #Function<1.72390911/1 in Cadex.handle_cast/2>
  },
  previous: %{box_A: 11, box_B: 0},
  sim: %{
    partial_state_update_blocks: [
      %PartialStateUpdateBlock{policies: [], variables: [:box_A, :box_B]}
    ],
    simulation_parameters: %SimulationParameters{M: %{}, N: 1, T: 10}
  }
}
%State{
  current: %{box_A: 9, box_B: 2},
  delta: %{
    box_A: #Function<2.72390911/1 in Cadex.handle_cast/2>,
    box_B: #Function<1.72390911/1 in Cadex.handle_cast/2>
  },
  previous: %{box_A: 10, box_B: 1},
  sim: %{
    partial_state_update_blocks: [
      %PartialStateUpdateBlock{policies: [], variables: [:box_A, :box_B]}
    ],
    simulation_parameters: %SimulationParameters{M: %{}, N: 1, T: 10}
  }
}
...
Finished in 0.08 seconds
5 tests, 0 failures

Randomized with seed 249053
```

## Installation

**This package is not available on Hex yet.**

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cadex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cadex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cadex](https://hexdocs.pm/cadex).

## Feature Parity

- [X] Basic state updates & policy functions (Robots and marbles tutorial 7)
- [ ] Monte carlo simulations / parameter sweeps

## Roadmap

1. Keep experimenting
2. Introduce concurrency with `flow`
3. Visualization with Phoenix LiveView and Scenic

## References

1. https://github.com/BlockScience/cadCAD
2. https://github.com/jgke/epidemic
