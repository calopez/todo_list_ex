defmodule TodoServer do
 @moduledoc "
 Study notes.
 When implementing a server process, it usually makes sense to put all of
 its code in a single module. The functions of this module generally fall
 in two categories: interface and implementation.

 Interface functions are public and are executed in the caller process.
 They hide the details of process creation and the communication protocol.

 Implementation functions are usually private and run in the server process.
"

  def start do
    spawn(fn -> loop(TodoList.new) end)
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      message -> process_message(todo_list, message)
    end
    loop(new_todo_list)

  end # end loop

  # ------------------------------------------------------------
  #                       Interface
  # ------------------------------------------------------------

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self, date})

    receive do
      {:todo_entries, entries} -> entries
                    after 5000 -> {:error, :timeout}
    end
  end

  # ------------------------------------------------------------
  #                         Implementation
  # ------------------------------------------------------------


  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end
end

defmodule TodoList do

  defstruct auto_id: 1, entries: HashDict.new


  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList,
      #fn(entry, todo_list_acc) -> add_entry(todo_list_acc, entry) end
      &add_entry(&2, &1) # capture version is definitely shorter, but it’s
                         # arguably more cryptic.
    )
  end
  #----------------------------------------------------------------------
  #                            ADD ENTRY
  #----------------------------------------------------------------------

  def add_entry(
        %TodoList{entries: entries, auto_id: auto_id} = todo_list, entry
      ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  #----------------------------------------------------------------------
  #                         GET ENTRIES
  #----------------------------------------------------------------------

  def entries(%TodoList{entries: entries}, date) do
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
        %TodoList{entries: entries} = todo_list, entry_id, updater_fun
      ) do
    case entries[entry_id] do
      nil -> todo_list
      old_entry ->
        # assert that the id value of the entry has not been changed
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.()

        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end

  end

  #----------------------------------------------------------------------
  #                         DELETE AN ENTRY
  #----------------------------------------------------------------------

  def delete_entry(%TodoList{entries: entries} = todoList, entry_id) do

    %TodoList{todoList | entries: HashDict.delete(entries, entry_id)}

  end

end

