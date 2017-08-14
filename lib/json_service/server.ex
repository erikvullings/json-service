defmodule JsonService.Server do
  use Supervisor

  alias JsonService.Cache

  defp create_list(name) do
    Supervisor.start_child(__MODULE__, [name])
  end

  def find_list(name) do
    Enum.find lists(), fn(child) ->
      JsonService.List.name(child) == name
    end
  end

  def find_or_create_list(name) do
    found = Enum.find lists(), fn(child) ->
      JsonService.List.name(child) == name
    end
    { :ok, found } = case found do
      nil -> create_list name
      _ -> { :ok, found }
    end
    found
  end

  def delete_list(list) do
    Supervisor.terminate_child(__MODULE__, list)
  end

  def lists() do
    __MODULE__
    |> Supervisor.which_children
    |> Enum.map(fn({_, child, _, _}) -> child end)
  end

  def populate_lists() do
    Enum.map(Cache.get_lists,
      fn({_, list}) ->
        create_list(to_string(list.name))
      end
    )
  end


  ###
  # Supervisor API
  ###

  def start_link do
    server = Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    populate_lists()
    server
  end

  def init(_) do
    children = [
      worker(JsonService.List, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end