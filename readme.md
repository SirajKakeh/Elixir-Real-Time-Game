#  Elixir React Real-Time Game

A real-time game built with Elixir/React

## installation
- `cd server && mix deps.get`
- `iex -S mix phx.server`
- Inside the iex shell enter `Game.GameSupervisor.start_child("0")`. This will create a game with ID: `0`
- `cd ../client && npm i`
- `npm start`
- Open game client on [localhost:3000](http://localhost:3000/)
- New players can join by opening [localhost:3000](http://localhost:3000/) from an `Incognito` window and game can be played in real time on the two pages
