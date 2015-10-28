defmodule TodoServer do
  @moduledoc """
  Study notes.
  When implementing a server process, it usually makes sense to put all of
  its code in a single module. The functions of this module generally fall
  in two categories: interface and implementation.
  Interface functions are public and are executed in the caller process.
  They hide the details of process creation and the communication protocol.
  Implementation functions are usually private and run in the server process.
  ## Example
      iex(2)> {:ok, pid} = TodoServer.start_link
      {:ok, #PID<0.65.0>}
      iex(3)> TodoServer.add_entry(pid, %{date: {2013, 12, 19}, title: "Dentist"})
      :ok
      iex(4)> TodoServer.add_entry(pid, %{date: {2013, 12, 20}, title: "Shopping"})
      :ok
      iex(5)> TodoServer.add_entry(pid, %{date: {2013, 12, 19}, title: "Movies"})
      :ok
      iex(6)> TodoServer.entries(pid, {2013, 12, 19})
      [%{date: {2013, 12, 19}, id: 3, title: "Movies"},
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"}]
      iex(7)> TodoServer.entries(pid, {2013, 12, 20})
      [%{date: {2013, 12, 20}, id: 2, title: "Shopping"}]

  """


  use GenServer

  # ------------------------------------------------------------
  #                       Interface
  # ------------------------------------------------------------

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end


  # ------------------------------------------------------------
  #         Implementation (callbacks for GenServer)
  # ------------------------------------------------------------

  def init(_) do
    {:ok, TodoList.new}
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do #(msg, state)

    todo_list = TodoList.add_entry(todo_list, new_entry)
    {:noreply, todo_list}

  end

  def handle_call({:entries, date},_, todo_list) do #(msg, {from, ref}, state)
    list = TodoList.entries(todo_list, date)
    {:reply, list, todo_list}

  end

end


# ------------------------------------------------------------
# ------------------------------------------------------------
#              TodoList Module (Data Abstraction)
# ------------------------------------------------------------
# ------------------------------------------------------------


defmodule TodoList do

  defstruct auto_id: 1, entries: HashDict.new


  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
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

