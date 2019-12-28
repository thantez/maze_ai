defmodule MazeServer.MazeAi.IDS do
  alias MazeServer.MazeAi

  def frontier_pop(frontier) do
    List.pop_at(frontier, -1)
  end

  def frontier_push(frontier, point) do
    List.insert_at(frontier, -1, point)
  end

  def lds_search(limit, board, point) do
    root = MazeAi.create_point(point, board, nil, fn _, _ -> 0 end, {}, nil)
    case MazeAi.graph_search([root], [], board, "2", "1", limit,
          &frontier_pop/1, &frontier_push/2) |> List.flatten do
            [:error] -> [:error]
            [:error|_] -> lds_search(limit+1, board, point)
            [:ok, target_point, explored_set|_] -> [:ok, target_point, explored_set]
            result -> result
    end
  end

  def search(board \\ MazeAi.init_board, point \\ %{x: 1, y: 14}) do
    lds_search(0, board, point)
  end
end
