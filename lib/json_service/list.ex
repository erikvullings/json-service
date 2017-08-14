defmodule JsonService.List do
  use GenServer

  alias JsonService.Cache

  def name(list) do
    GenServer.call(list, :name)
  end

  def items(list) do
    GenServer.call(list, :items)
  end

  @doc """
  Finds the first element in a list by ID.
  """
  def item(list, id) do
    GenServer.call(list, { :item, id })
  end

  def add(list, item) do
    GenServer.cast(list, {:add, item})
  end

  def delete(list, id) do
    GenServer.cast(list, {:delete, id})
  end

  def update(list, item) do
    GenServer.cast(list, {:update, item})
  end

  ###
  # GenServer API
  ###

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def init(name) do
    state = Cache.find(name) || %{name: name, items: []}
    Cache.save(state)
    {:ok, state}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end

  def handle_call(:items, _from, state) do
    {:reply, state.items, state}
  end

  def handle_call({:item, id}, _from, state) do
    # IO.puts "Filtering item with id: #{id}"
    item = Enum.find state.items, fn(item) -> item.id == id end
    # IO.inspect item
    {:reply, item, state}
  end

  def handle_cast({:delete, id}, state) do
    # IO.puts "Add item"
    # IO.puts inspect item
    # IO.puts "State"
    # IO.puts inspect state
    items = Enum.filter state.items, fn(item) -> item.id != id end
    state = %{state | items: items }
    Cache.save(state)
    {:noreply, state}
  end

  def handle_cast({:add, item}, state) do
    # IO.puts "Add item"
    # IO.puts inspect item
    # IO.puts "State"
    # IO.puts inspect state
    state = %{state | items: [item | state.items]}
    Cache.save(state)
    {:noreply, state}
  end

  def handle_cast({:update, item}, state) do
    index = Enum.find_index(state.items, &(&1.id == item.id))
    items = List.replace_at(state.items, index, item)
    state = %{state | items: items}
    Cache.save(state)
    {:noreply, state}
  end
end