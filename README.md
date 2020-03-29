# Cadex

An Elixir GenServer module based on the popular Python package [cadCAD](https://cadcad.org): "Design, test and validate complex systems through simulation in Python".

This is an exercise in better understanding system modelling, simulation, complex systems, and the design of cadCAD. 

It also serves as a learning exercise in the Erlang/Elixir OTP actor model and GenServer based programming constructs! In fact, it is the OTP actor model that originally made me think of the similarities to graph theory and the way state is managed in complex system modelling.

Designing a differential games engine also uses all the best features of the Elixir language: it is functional, expressive, has great data constructs, pattern matching, scalability, it enables creating maintainable code, and has incredible tooling.

## Installation

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

## References

1. https://github.com/jgke/epidemic