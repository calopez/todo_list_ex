defmodule TodoList do

  def new, do: HashDict.new

  @doc """
  add a new entry to the todo list
  """
  def add_entry(todo_list, data, title) do
    HashDict.update(todo_list,
                    date,
                    [title],
                    fn(titles) -> [title | titles] end
    )
  end

  @doc """
  get all entries from the todo list
  """
  def entries(todo_list, date) do
    HashDict.get(todo_list, date, [])
  end


end
