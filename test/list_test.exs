defmodule JsonService.ListTest do
  use ExUnit.Case

  alias JsonService.List
  alias JsonService.Intervention
  alias JsonService.Cache

  setup do
    {:ok, list} = List.start_link("Home")

    on_exit fn ->
      Cache.clear
    end

    {:ok, list: list}
  end

  test ".items returns the JsonServices on the list", %{list: list} do
    assert List.items(list) == []
  end

  test ".add adds an item to the list", %{list: list} do
    item = Intervention.new("from", "to", "type", "subtype", "Create an OTP app")

    List.add(list, item)
    assert List.items(list) == [item]
  end

  test ".update can update an item", %{list: list} do
    item = Intervention.new("from", "to", "type", "subtype", "Complete a task")
    List.add(list, item)

    # Update the item
    item = %{item | comment: "new"}
    List.update(list, item)

    # Assert that the item was updated
    assert List.items(list) == [item]
  end
end