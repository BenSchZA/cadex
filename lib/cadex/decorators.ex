defmodule Cadex.Decorators do
  @moduledoc """
  Decorate Cadex policy and state update functions
  """

  use Decorator.Define, [state_update: 1]

  def state_update(variable, body, context) do
    quote do
      IO.puts("State update function called: " <> Atom.to_string(unquote(context.name)) <> " on " <> to_string(unquote(variable)))
      unquote(body)
    end
  end

  # defmacro @state_update(call) do
  #   quote do
  #     Kernel.@(unquote(call))
  #   end
  #   # case call do
  #   #   {:dok, _, [name]} when is_binary(name) ->
  #   #     quote do
  #   #       Kernel.@(doc unquote(SectionsCache.get_contents(__MODULE__, {"doc", name})))
  #   #     end

  #   #   {:typedok, _, [name]} when is_binary(name) ->
  #   #     quote do
  #   #       Kernel.@(typedoc unquote(SectionsCache.get_contents(__MODULE__, {"typedoc", name})))
  #   #     end

  #   #   {:moduledok, _, [name]} when is_binary(name)  ->
  #   #     quote do
  #   #       Kernel.@(moduledoc unquote(SectionsCache.get_contents(__MODULE__, {"moduledoc", name})))
  #   #     end

  #   #   _ ->
  #   #     quote do
  #   #       Kernel.@(unquote(call))
  #   #     end
  #   end

  # end

  # defmacro __using__(opts) do #when is_atom(file) do
  #   quote do
  #     # import Kernel, except: [@: 1]
  #     import Cadex.Decorators
  #   end
  # end
end
