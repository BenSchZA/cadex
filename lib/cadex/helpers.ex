defmodule StructPipe do
  defmacro left ~>> right do
    {:%{}, [], [{:|, [], [left, right]}]}
  end
end
