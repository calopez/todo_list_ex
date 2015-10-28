defmodule Todo.Server do
  @moduledoc """
  Study notes.
  When implementing a server process, it usually makes sense to put all of
  its code in a single module. The functions of this module generally fall
  in two categories: interface and implementation.
  Interface functions are public and are executed in the caller process.
  They hide the details of process creation and the communication protocol.
  Implementation functions are usually private and run in the server process.
  ## Example
      iex(2)> {:ok, pid} = Todo.Server.start_link
      {:ok, #PID<0.65.0>}
      iex(3)> Todo.Server.add_entry(pid, %{date: {2013, 12, 19}, title: "Dentist"})
      :ok
      iex(4)> Todo.Server.add_entry(pid, %{date: {2013, 12, 20}, title: "Shopping"})
      :ok
      iex(5)> Todo.Server.add_entry(pid, %{date: {2013, 12, 19}, title: "Movies"})
      :ok
      iex(6)> Todo.Server.entries(pid, {2013, 12, 19})
      [%{date: {2013, 12, 19}, id: 3, title: "Movies"},
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"}]
      iex(7)> Todo.Server.entries(pid, {2013, 12, 20})
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
    {:ok, Todo.List.new}
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do #(msg, state)

    todo_list = Todo.List.add_entry(todo_list, new_entry)
    {:noreply, todo_list}

  end

  def handle_call({:entries, date},_, todo_list) do #(msg, {from, ref}, state)
    list = Todo.List.entries(todo_list, date)
    {:reply, list, todo_list}

  end

end
