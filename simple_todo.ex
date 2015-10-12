defmodule TodoList do
  defstruct auto_id: 1, entries: HashDict.new

  def new, do: %TodoList{}

end
