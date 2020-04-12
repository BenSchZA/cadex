defmodule PythonInterface do
  use Export.Python

  def plot(x1, x2) do
    {:ok, py} = Python.start(python_path: Path.expand("lib/python"))
    py |> Python.call(marbles_plot(x1, x2), from_file: "pyplot")
  end

  def plot_marble_runs(x1_runs, x2_runs) do
    {:ok, py} = Python.start(python_path: Path.expand("lib/python"))
    py |> Python.call(plot_marble_runs(x1_runs, x2_runs), from_file: "pyplot")
  end
end
