defmodule GameWeb.GameChannel do
  use GameWeb, :channel

  require Logger

  alias Game.GameServer

  @impl true
  def join("games:" <> game_id, _params, socket) do
    game = GameServer.add_player(game_id, socket.assigns.user_id)

    Logger.info("USER: #{socket.assigns.user_id} SUCCEFULLY JOINED GAME!")

    {:ok, %{"game" => encode_game(game)}, socket}
  end

  @impl true
  def handle_in("action:move", %{"key_code" => key_code}, socket) do
    direction = get_direction(key_code)
    game = GameServer.move_player("0", socket.assigns.user_id, direction)
    Phoenix.Channel.broadcast!(socket, "change", %{"game" => encode_game(game)})
    {:noreply, socket}
  end

  defp get_direction(key_code) do
    case key_code do
      37 -> :left
      38 -> :up
      39 -> :right
      40 -> :down
    end
  end

  defp encode_game(game), do: Jason.encode!(Enum.map(game, &Map.from_struct(&1)))
end
