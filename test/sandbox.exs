defmodule Test do
  defmacro state(call, expr) do
    # caller = __CALLER__
    IO.inspect call
    IO.inspect expr

    # import Kernel
    quote do
      Kernel.def unquote(call) do
        IO.puts "parent"
        apply(__MODULE__, unquote(expr))
      end
    end
  end
end

defmodule State do
  import Test
  state function(param) do
    IO.inspect param
  end
end

defmodule SandboxTest do
  use ExUnit.Case, async: true
  import Test
  import State

  # test "state" do
  #   IO.puts function(:param)
  #   assert true
  # end
end
