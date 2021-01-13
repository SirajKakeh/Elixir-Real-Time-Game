import "./Square.css";

function Square({ occupier, walkable, userId }) {
  const getRepresentation = (occupier, userId) => {
    if (!walkable) {
      return "⛔";
    }
    switch (occupier) {
      case null:
        return "";
      default:
        return String(userId) === occupier ? "😊" : "😈";
    }
  };
  return <div className="square">{getRepresentation(occupier, userId)}</div>;
}

export default Square;
