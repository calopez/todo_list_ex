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

  def handle_call({:get, key}, _, db_folder) do
    {_, response}= File.read(file_name(db_folder, key)) 
    data = case response do
             {:ok, contents} -> :erlang.binary_to_term(contents)
                           _ -> nil
           end
    {:reply, data, db_folder}
  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"

end
