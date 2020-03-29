alias :mnesia, as: Mnesia

Mnesia.create_schema([node()])
Mnesia.start()
Mnesia.create_table(State, [attributes: [:id, :tick, :index, :current]])

###

state = %State{previous: _previous, current: _current} = Cadex.state
Cadex.update(var)
_state_ = %State{previous: _previous_, current: current_} = Cadex.state

Mnesia.dirty_write({
  State,
  Kernel.inspect(tick) <> Kernel.inspect(index),
  tick,
  index,
  current_
})
:sys.replace_state(context[:pid], fn _s -> state end)

###

{result, states} = Mnesia.transaction(
  fn ->
    Mnesia.select(
      State,
      [{
        {State, :"$1", :"$2", :"$3", :"$4"},
        [{:==, :"$2", tick}],
        [:"$4"]
      }]
    )
  end
)
case result do
  :atomic ->
    :sys.replace_state(context[:pid], fn s -> {s | states} end)
  _ ->
    :nothing
end
data = variables
|> Enum.with_index
|> Enum.map(fn({_var, index}) ->
  Mnesia.transaction(fn -> Mnesia.match_object({State, tick, index, :_}) end)
end)




# delta_ = %{var => increment}

# state
# |> update_in([Access.key!(:delta), Access.key!(var)], fn(var) ->
#   increment
# end)

# state
# |> struct(%{delta: delta_})

{
  :noreply,

  state
  |> update_in([Access.key!(:delta), Access.key!(var)], fn ->
    increment
  end)
}
