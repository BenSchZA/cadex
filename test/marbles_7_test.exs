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
      assert {:ok, runs} = Cadex.run(debug=false)

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
    end
  end
end
