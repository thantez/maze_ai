defmodule MazeServerWeb.MazeSocketChannel do
  use MazeServerWeb, :channel

  def join("maze_socket:lobby", _, socket) do
    {:ok, socket}
  end

  def handle_in("bfs", %{"board" => board,
                                "start_p" =>  %{"x" => x, "y" => y}}, socket) do
    result = %{result: MazeServer.MazeAi.BFS.search(board, %{x: x, y: y})}
    {:reply, {:ok, result}, socket}
  end

  def handle_in("ids", %{"board" => board,
                                "start_p" =>  %{"x" => x, "y" => y}}, socket) do
    result = %{result: MazeServer.MazeAi.IDS.search(board, %{x: x, y: y})}
    {:reply, {:ok, result}, socket}
  end

  def handle_in("astar", %{"board" => board,
                                "start_p" =>  %{"x" => x, "y" => y}}, socket) do
    result = %{result: MazeServer.MazeAi.AStar.search(board, %{x: x, y: y})}
    {:reply, {:ok, result}, socket}
  end
end
