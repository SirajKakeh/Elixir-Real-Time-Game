/* eslint-disable react-hooks/exhaustive-deps */
/* eslint-disable no-unused-vars */
import { useEffect, useState } from "react";
import { Socket } from "phoenix";

import "./App.css";
import Square from "./Square";

function App() {
  const [userId] = useState(Math.round(Math.random() * 10 ** 12));
  const [squares, setSquares] = useState(Array(81).fill(0));
  const [userLocation] = useState(Math.floor(Math.random() * 81));

  const [socket] = useState(
    new Socket("ws://localhost:4000/socket", { params: { user_id: userId } })
  );
  const [channel] = useState(socket.channel(`games:${0}`));

  const handleKeyPress = ({ keyCode }) => {
    if ([37, 38, 39, 40].includes(keyCode)) {
      channel.push("action:move", { key_code: keyCode });
    }
  };

  useEffect(() => {
    socket.connect();
    channel
      .join()
      .receive("ok", (responsePayload) => {
        console.log("Message from server: ", responsePayload);
        if (responsePayload["game"]) {
          setSquares(JSON.parse(responsePayload["game"]));
        }
      })
      .receive("error", console.error);
    channel.on("change", ({ game }) => setSquares(JSON.parse(game)));
    document.addEventListener("keydown", handleKeyPress);
  }, []);

  return (
    <section className="game">
      {squares.map(({ walkable, occupier }, index) => (
        <Square
          key={index}
          occupier={occupier}
          walkable={walkable}
          userId={userId}
        />
      ))}
    </section>
  );
}

export default App;
