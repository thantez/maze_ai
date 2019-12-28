defmodule MazeServer.MazeAi.BFS do
  alias MazeServer.MazeAi

  def frontier_pop(frontier) do
    List.pop_at(frontier, 0)
  end

  def frontier_push(frontier, point) do
    List.insert_at(frontier, -1, point)
  end

  def search(board \\ MazeAi.init_board, point \\ %{x: 1, y: 14}) do
    root = MazeAi.create_point(point, board, nil,  fn _, _ -> 0 end, {}, nil)
    MazeAi.graph_search([root], [], board, "2", "1", -1,
      &frontier_pop/1, &frontier_push/2)
  end
end
