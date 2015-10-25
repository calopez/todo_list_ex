defmodule TodoServer do
  @moduledoc "
  Study notes.
  When implementing a server process, it usually makes sense to put all of
  its code in a single module. The functions of this module generally fall
  in two categories: interface and implementation.
  Interface functions are public and are executed in the caller process.
  They hide the details of process creation and the communication protocol.
  Implementation functions are usually private and run in the server process. "

  def start do
    ServerProcess.start(__MODULE__)
  end

  # ------------------------------------------------------------
  #                       Interface
  # ------------------------------------------------------------

  def init do
    TodoList.new
  end

  def add_entry(new_entry) do
    ServerProcess.cast({:add_entry, new_entry})
  end

  def entries(date) do
    ServerProcess.call({:entries, date})
  end


  # ------------------------------------------------------------
  #         Implementation (callbacks for ServerProcess)
  # ------------------------------------------------------------

  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.add_entry(todo_list, new_entry)
  end

  def handle_call({:entries, date}, todo_list) do
    list = TodoList.entries(todo_list, date)
    {list, todo_list}
  end

end


defmodule ServerProcess do
  @moduledoc " Abstraction for the generic server process."

  def start(callback_module) do
    pid = spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
    Process.register(pid, :todo_server)
  end

  # function to issue requests to the server process
  def call(request, timeout \\ 5000) do
    send(:todo_server, {:call, request, self})

    receive do
      {:response, response} -> response
              after timeout -> {:error, :timeout}
    end
  end

  def cast(request) do
    send(:todo_server, {:cast, request})
  end

  # handling messages in the server process
  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request,
                                                            current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        IO.inspect new_state
        loop(callback_module, new_state)
    end
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

