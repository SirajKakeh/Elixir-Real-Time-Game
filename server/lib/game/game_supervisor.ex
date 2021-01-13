defmodule Game.GameSupervisor do
  use DynamicSupervisor

  alias Game.GameServer

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(game_id) do
    # Shorthand to retrieve the child specification from the `child_spec/1` method of the given module.
    child_specification = {GameServer, game_id}

    DynamicSupervisor.start_child(__MODULE__, child_specification)
  end

  @impl true
  def init(_arg) do
    # :one_for_one strategy: if a child process crashes, only that process is restarted.
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
