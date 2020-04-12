defmodule Marbles7Test do
  use ExUnit.Case, async: false
  doctest Marbles7
  import Cadex.Types
  alias Cadex.Types
  alias Marbles7
  import ExProf.Macro

  setup do
    {:ok, pid} = Cadex.start(Marbles7)
    {:ok, %{pid: pid}}
  end

  test "cadex run" do
    # %Cadex.Types.State{} = state
    profile do
      assert {:ok, results} = Cadex.run(debug=false)

      %{run: run, result: run_results} = results |> List.first
      box_A_plot = run_results |> Enum.map(fn result ->
        %{timestep: timestep, state: state} = result |> List.last
        %{box_A: box_A, box_B: box_B} = state |> List.last
        box_A
      end)

      box_B_plot = run_results |> Enum.map(fn result ->
        %{timestep: timestep, state: state} = result |> List.last
        %{box_A: box_A, box_B: box_B} = state |> List.last
        box_B
      end)

      PythonInterface.plot(box_A_plot, box_B_plot)
    end
  end
end
