defmodule Todo.List do

  defstruct auto_id: 1, entries: HashDict.new


  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{},
      #fn(entry, todo_list_acc) -> add_entry(todo_list_acc, entry) end
      &add_entry(&2, &1) # capture version is definitely shorter, but it’s
                         # arguably more cryptic.
    )
  end
  #----------------------------------------------------------------------
  #                            ADD ENTRY
  #----------------------------------------------------------------------

  def add_entry(
        %Todo.List{entries: entries, auto_id: auto_id} = todo_list, entry
      ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)

    %Todo.List{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  #----------------------------------------------------------------------
  #                         GET ENTRIES
  #----------------------------------------------------------------------

  def entries(%Todo.List{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) -> entry.date == date end)
    |> Enum.map(fn({_, entry}) -> entry end) # only return values
  end

  #----------------------------------------------------------------------
  #                         UPDATE AN ENTRY
  #----------------------------------------------------------------------

  def update_entry(todo_list, %{} = new_entry) do
    # we have provided an alternative interface, The updater lambda
    # ignores the old value and returns the new entry.
    update_entry(todo_list, new_entry.id, fn(_) -> new_entry end)
  end

  defp update_entry(
        %Todo.List{entries: entries} = todo_list, entry_id, updater_fun
      ) do
    case entries[entry_id] do
      nil -> todo_list
      old_entry ->
        # assert that the id value of the entry has not been changed
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.()

        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end

  end

  #----------------------------------------------------------------------
  #                         DELETE AN ENTRY
  #----------------------------------------------------------------------

  def delete_entry(%Todo.List{entries: entries} = todoList, entry_id) do

    %Todo.List{todoList | entries: HashDict.delete(entries, entry_id)}

  end

end

