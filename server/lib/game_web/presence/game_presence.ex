defmodule GameWeb.Presence do
  use Phoenix.Presence,
    otp_app: :game,
    pubsub_server: Game.PubSub
end
