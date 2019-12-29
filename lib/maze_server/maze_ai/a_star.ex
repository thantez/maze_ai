defmodule MazeServer.MazeAi.AStar do
  alias MazeServer.MazeAi

  @moduledoc """
  this module define A* rules.
  in this algorithm, frontier is same as BFS with a tiny difference!
  frontier will sort by ascending `path_cost` order after every push.
  """

  @doc """
  this expander is same as `MazeAi.expander` but it will check path_cost for expand a node!
  """
  def expander(frontier, point, explored_set, frontier_push) do
    unless Enum.any?(explored_set, &(&1.x == point.x and &1.y == point.y)) or point.state == "1" do
      p_index =
        Enum.find_index(
          frontier,
          &(&1.x == point.x and &1.y == point.y and point.path_cost < &1.path_cost)
        )

      new_frontier =
        unless p_index == nil do
          List.delete_at(frontier, p_index)
        else
          frontier
        end

      frontier_push.(new_frontier, point)
    else
      frontier
    end
  end

  @doc """
  frontier pop rule for A*.
  """
  def frontier_pop(frontier) do
    List.pop_at(frontier, 0)
  end

  @doc """
  frontier push rule for A*.
  it will sort frontier by ascending `path_cost` order.
  """
  def frontier_push(frontier, point) do
    List.insert_at(frontier, -1, point)
    |> Enum.sort(fn %{path_cost: pc1}, %{path_cost: pc2} -> pc1 <= pc2 end)
  end

  @doc """
  heuristic calculation with diagonal distance calculator.
  ## Examples

      iex> MazeServer.MazeAi.AStar.h({1, 2}, {4, 5})
      6

  and this is true:
  __2 * max((4-1), (5-2)) = 6__
  """
  def h({x, y}, {end_x, end_y}) do
    d1 = abs(end_x - x)
    d2 = abs(end_y - y)
    # Diagonal Distance
    2 * max(d1, d2)
  end

  @doc """
  it will calculates path cost of a node with path cost of its parent node plus one!
  """
  def g(path_cost, _) do
    path_cost + 1
  end

  @doc """
  A* search. it will search same as BFS.
  """
  def search(board \\ MazeAi.init_board(), point \\ %{x: 1, y: 14}) do
    target = MazeAi.find_target(board)
    root = MazeAi.create_point(point, board, nil, &h/2, target, nil)

    MazeAi.graph_search(
      [root],
      [],
      target,
      board,
      "2",
      "1",
      -1,
      &g/2,
      &h/2,
      &frontier_pop/1,
      &frontier_push/2,
      &expander/4
    )
  end
end
