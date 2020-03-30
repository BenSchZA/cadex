# Cadex

An Elixir GenServer module based on the popular Python package [cadCAD](https://cadcad.org): "Design, test and validate complex systems through simulation in Python".

This is an exercise in better understanding system modelling, simulation, complex systems, and the design of cadCAD. 

It also serves as a learning exercise in the Erlang/Elixir OTP actor model and GenServer based programming constructs! In fact, it is the OTP actor model that originally made me think of the similarities to graph theory and the way state is managed in complex system modelling.

Designing a differential games engine also uses all the best features of the Elixir language: it is functional, expressive, has great data constructs, pattern matching, scalability, it enables creating maintainable code, and has incredible tooling.

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

## Roadmap

1. Keep experimenting
2. Introduce concurrency with `flow`
3. Visualization with Phoenix LiveView and Scenic

## References

1. https://github.com/jgke/epidemic
