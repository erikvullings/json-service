defmodule JsonService.Cache do
  use GenServer

  import String, only: [to_atom: 1]

  def save(list) do
    :ets.insert(__MODULE__, {to_atom(list.name), list})
  end

  def find(list_name) do
    case :ets.lookup(__MODULE__, to_atom(list_name)) do
      [{_id, value}] -> value
      [] -> nil
    end
  end

  def get_lists do
    :ets.tab2list(__MODULE__)
  end

  def clear do
    :ets.delete_all_objects(__MODULE__)
  end


  ###
  # GenServer API
  ###

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    table = PersistentEts.new(__MODULE__, "interventions.tab", [:named_table, :public])
    IO.puts "Created database #{__MODULE__}"
    {:ok, table}
  end
end
