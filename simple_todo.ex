defmodule TodoList do

  defstruct auto_id: 1, entries: HashDict.new

  def new, do: %TodoList{}

  def add_entry(
        %TodoList{entries: entries, auto_id: auto_id} = todo_list, entry
      ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) -> entry.date == date end)
    |> Enum.map(fn({_, entry}) -> entry end) # only return values
  end

end

# todo_list = TodoList.new |>
#   TodoList.add_entry(
#     %{date: {2013, 12, 19}, title: "Dentist"}
#   ) |>
#   TodoList.add_entry(
#     %{date: {2013, 12, 20}, title: "Shopping"}
#   ) |>
#   TodoList.add_entry(
#     %{date: {2013, 12, 19}, title: "Movies"}

# TodoList.entries(todo_list, {2013, 12, 19})
