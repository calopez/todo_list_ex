defmodule MultiDict do
  def new, do: HashDict.new

  def add(dic, key, value) do
    HashDict.update(
      dic,
      key,
      [value],
      &[value | &1]
    )
  end

  def get(dic, key) do
    HashDict.get(dic, key, [])
  end
end

defmodule TodoList do

  def new, do: MultiDict.new

  @doc """
  add a new entry to the todo list
  """
  def add_entry(todo_list, entry) do
    MultiDict.add(todo_list, entry.date, entry)
  end

  @doc """
  get all entries from the todo list
  """
  def entries(todo_list, date) do
    MultiDict.get(todo_list, date)
  end

end
