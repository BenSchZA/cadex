defmodule EIP1559Test do
  use ExUnit.Case, async: false
  doctest EIP1559
  alias EIP1559
  import ExProf.Macro

  setup do
    {:ok, pid} = Cadex.start(EIP1559)
    {:ok, %{pid: pid}}
  end

  test "cadex run" do
    # %Cadex.Types.State{} = state
    profile do
      assert {:ok, runs} = Cadex.run()
      # IO.inspect runs
    end
  end
end
