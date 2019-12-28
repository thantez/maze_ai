defmodule MazeServer.MazeAi.AStar do
  alias MazeServer.MazeAi

  def expander(frontier, point, explored_set, frontier_push) do
    unless Enum.any?(explored_set, &(&1.x == point.x and &1.y == point.y)) or point.state == "1" do
      p_index = Enum.find_index(frontier, &(&1.x == point.x and &1.y == point.y and point.path_cost < &1.path_cost))
      new_frontier = unless p_index == nil do
        List.delete_at(frontier, p_index)
      else
        frontier
      end
      frontier_push.(new_frontier, point)
    else
      frontier
    end
  end

  def frontier_pop(frontier) do
    List.pop_at(frontier, 0)
  end

  def frontier_push(frontier, point) do
    List.insert_at(frontier, -1, point)
    |> Enum.sort(fn %{path_cost: pc1}, %{path_cost: pc2} -> pc1 <= pc2 end)
    |> IO.inspect
  end

  @doc """
  heuristic calculation with nmanhattan distance calculator
  # Example

  """
  def h({x, y}, {end_x, end_y}) do
    d1 = abs(end_x-x)
    d2 = abs(end_y-y)
    d1+d2
  end

  def g(path_cost, _) do
    path_cost+1
  end

  def search(board \\ MazeAi.init_board, point \\ %{x: 1, y: 14}) do
    target = MazeAi.find_target(board)
    root = MazeAi.create_point(point, board, nil, &h/2, target, nil)
    MazeAi.graph_search([root], [], target, board, "2", "1", -1, &g/2, &h/2,
      &frontier_pop/1, &frontier_push/2, &expander/4)
  end
end
