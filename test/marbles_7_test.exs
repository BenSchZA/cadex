defmodule Marbles7Test do
  use ExUnit.Case, async: false
  @moduletag timeout: :infinity
  doctest Marbles7
  alias Marbles7
  import ExProf.Macro

  setup do
    {:ok, pid} = Cadex.start(Marbles7)
    {:ok, %{pid: pid}}
  end

  test "cadex run" do
    # %Cadex.Types.State{} = state
    {_records, {:ok, runs}} = profile do
      Cadex.run(debug=false)
    end

    # IO.inspect runs

    box_A_plots = runs |> Enum.map(fn %{run: _run, result: result} ->
      result |> Enum.map(fn timestep ->
        %{state: state} = timestep |> List.last
        %{box_A: box_A} = state
        box_A
      end)
    end)

    box_B_plots = runs |> Enum.map(fn %{run: _run, result: result} ->
      result |> Enum.map(fn timestep ->
        %{state: state} = timestep |> List.last
        %{box_B: box_B} = state
        box_B
      end)
    end)

    PythonInterface.plot_marble_runs(box_A_plots, box_B_plots)
  end
end
