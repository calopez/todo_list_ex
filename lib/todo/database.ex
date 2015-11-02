defmodule Todo.Database do
  use GenServer

  # ------------------------------------------------------------
  #                       Interface
  # ------------------------------------------------------------

  def start(db_folder) do
    GenServer.start(__MODULE__,
                    db_folder,
                    name: :database_server) #Locally registers the process
  end

  def store(key, data) do
    db_worker = get_worker(key)
    Todo.DatabaseWorker.store(db_worker, key, data)
  end

  def get(key) do
    db_worker = get_worker(key)
    Todo.DatabaseWorker.get(db_worker,  key)
  end

  defp get_worker(key) do
    GenServer.call(:database_server, {:get_worker, key})
  end

  # ------------------------------------------------------------
  #         Implementation (callbacks for GenServer)
  # ------------------------------------------------------------

  def init(db_folder) do

    file = File.mkdir_p(db_folder) # Makes sure the folder exist

    w = Enum.reduce(0..2, %{},
      fn(key, workers) ->
        pid = Todo.DatabaseWorker.start(db_folder)
        Map.put(workers, key, pid)
      end
    )
    {:ok, {db_folder, w}}
  end

  def handle_call({:get_worker, key}, _, state = {_ , workers}) do
    {:ok, worker} = Map.get(workers, :erlang.phash2(key, 3) , nil)
    {:reply, worker, state}
  end

end
