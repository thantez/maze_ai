defmodule MazeServer.MazeAi.IDS do
  alias MazeServer.MazeAi

  @moduledoc """
  this module define IDS rules.
  in this algorithm, frontier is same as stack!
  """

  @doc """
  frontier pop rule for IDS
  this function will remove last node of list. (Last out)
  """
  def frontier_pop(frontier) do
    List.pop_at(frontier, -1)
  end

  @doc """
  frontier push rule for IDS
  this function will add any new node in the last of list. (First In)
  """
  def frontier_push(frontier, point) do
    List.insert_at(frontier, -1, point)
  end

  defp ids_search(limit, board, point) do
    root = MazeAi.create_point(point, board, nil, fn _, _ -> 0 end, {}, nil)

    case MazeAi.graph_search(
           [root],
           [],
           board,
           "2",
           "1",
           limit,
           &frontier_pop/1,
           &frontier_push/2
         )
         |> List.flatten() do
      [:error] -> [:error]
      [:error | _] -> ids_search(limit + 1, board, point)
      [:ok, target_point, explored_set | _] -> [:ok, target_point, explored_set]
      result -> result
    end
  end

  @doc """
  IDS search function. it simulate `for` loops with recursive solution.
  """
  def search(board \\ MazeAi.init_board(), point \\ %{x: 1, y: 14}) do
    ids_search(0, board, point)
  end
end
