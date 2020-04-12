defmodule PythonInterface do
  use Export.Python

  def plot(x1, x2) do
    {:ok, py} = Python.start(python_path: Path.expand("lib/python"))
    result = py |> Python.call(marbles_plot(x1, x2), from_file: "pyplot")

    # close the Python process
    # py |> Python.close()

    result
  end
end
