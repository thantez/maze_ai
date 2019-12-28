defmodule MazeServerWeb.PageController do
  use MazeServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
