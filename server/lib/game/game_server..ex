defmodule Game.GameServer do
  use GenServer

  require Logger

  alias Game.GameSquare

  @registry :game_registry
  @grid_size 9
  @free_blocks_threshold 0.8

  @type move_direction :: :up | :right | :down | :left

  # Client

  def start_link(game_id) do
    Logger.info(
      "______________________ Game: #{game_id} has been instantiated ______________________ "
    )

    GenServer.start_link(__MODULE__, [], name: via_tuple(game_id))
  end

  def add_player(game_id, player_id) do
    [{game_pid, _}] = Registry.lookup(@registry, game_id)
    GenServer.call(game_pid, {:add_player, player_id})
  end

  @spec move_player(String.t(), String.t(), move_direction()) :: :ok
  def move_player(game_id, player_id, move_direction) do
    [{game_pid, _}] = Registry.lookup(@registry, game_id)
    GenServer.call(game_pid, {:move_player, player_id, move_direction})
  end

  @impl true
  def init(_state) do
    {:ok, generate_game()}
  end

  @impl true
  def handle_call({:add_player, player_id}, _from, game) do
    first_possible_index =
      Enum.find_index(game, fn square -> square.walkable == true and is_nil(square.occupier) end)

    available_square = Enum.at(game, first_possible_index)

    updated_game =
      game
      |> List.replace_at(first_possible_index, %GameSquare{available_square | occupier: player_id})

    {:reply, updated_game, updated_game}
  end

  @impl true
  def handle_call({:move_player, player_id, move_direction}, _from, game) do
    index = Enum.find_index(game, &(&1.occupier == player_id))

    destination_index =
      case move_direction do
        :up -> index - @grid_size
        :right -> index + 1
        :down -> index + @grid_size
        :left -> index - 1
      end

    updated_game = do_move_player(game, player_id, index, destination_index)
    {:reply, updated_game, updated_game}
  end

  @spec generate_game :: list(%GameSquare{})
  defp generate_game() do
    Enum.map(
      0..(@grid_size - 1),
      fn x ->
        Enum.map(0..(@grid_size - 1), fn y ->
          %GameSquare{
            x: x,
            y: y,
            walkable: if(:rand.uniform() > @free_blocks_threshold, do: false, else: true)
          }
        end)
      end
    )
    |> List.flatten()
  end

  defp via_tuple(name),
    do: {:via, Registry, {@registry, name}}

  @spec do_move_player(list(%GameSquare{}), String.t(), number(), number()) :: list(%GameSquare{})
  defp do_move_player(game, player_id, index, destination_index) do
    if destination_within_grid?(destination_index) and
         destination_free?(game, destination_index) do
      square = Enum.at(game, index)
      destination_square = Enum.at(game, destination_index)

      game
      |> List.replace_at(index, %GameSquare{square | occupier: nil})
      |> List.replace_at(destination_index, %GameSquare{
        destination_square
        | occupier: player_id
      })
    else
      game
    end
  end

  defp destination_within_grid?(destination_index),
    do: destination_index >= 0 and destination_index < @grid_size * @grid_size

  defp destination_free?(game, index),
    do: is_nil(Enum.at(game, index).occupier) and Enum.at(game, index).walkable == true
end
