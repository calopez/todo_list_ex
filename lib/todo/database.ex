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
    GenServer.cast(:database_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end

  # ------------------------------------------------------------
  #         Implementation (callbacks for GenServer)
  # ------------------------------------------------------------

  def init(db_folder) do
    file = File.mkdir_p(db_folder) # Makes sure the folder exist
    {:ok, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do

    file_name(db_folder, key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, caller, db_folder) do
    # The handler function spawns the new worker process and immediately
    # returns. While the worker is running, the database process can accept
    # new requests.
    # For synchronous this approach is slightly more complicated because
    # you have to return the response from the spawned worker process:

    spawn(fn ->
      data = case File.read(file_name(db_folder, key)) do
               {:ok, contents} -> :erlang.binary_to_term(contents)
                              _ > nil
      end
      # Responds from the spawned process
      GenServer.reply(caller, data)
    )
    {:noreply, db_folder}

  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"

end
