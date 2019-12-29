defmodule MazeServer.MazeAi do
  @moduledoc """
  this is an AI for maze game
  """

  @doc """
  this function will return main test board.
  """
  def init_board do
    [
      "1111111111111111111111",
      "1001100000000000110001",
      "1111111110000000000001",
      "1111000100000111111101",
      "1011100100000111111101",
      "1011100111000111111101",
      "1000000111000000000001",
      "1000000111000111111111",
      "1111110100000000000021",
      "1000000001000000000001",
      "1000000001000000000001",
      "1000000111110011000001",
      "1000000001000011000011",
      "1000000001000011010011",
      "1001000000000011010011",
      "1000000000000011010011",
      "1000000000000000010011",
      "1111000000000000010011",
      "1111011001110000010001",
      "1100011001110000011111",
      "1100011001110000011111",
      "1111111111111111111111"
    ]
  end

  @doc """
  `find_target` function when get a board, search in it then return `end_point`.
  #Example
  """
  def find_target(board) do
    x = board
    |> Enum.filter(&String.contains?(&1, "2"))
    |> Enum.at(0)
    |> String.to_charlist()
    |> Enum.find_index(&(&1 == ?2))
    y = board
    |> Enum.find_index(&String.contains?(&1, "2"))
    {x, y}
  end

  @doc """
  duty of `expander` is check frontier queue and explored set
  for avoiding of redundancy and revisiting a node.
  """
  def expander(frontier, point, explored_set, frontier_push) do
    unless Enum.any?(frontier, &(&1.x == point.x and &1.y == point.y)) or
    Enum.any?(explored_set, &(&1.x == point.x and &1.y == point.y)) or point.state == "1" do
      frontier_push.(frontier, point)
    else
      frontier
    end
  end

  @doc """
  `expand` function will use expander
  """
  def expand(%{x: x, y: y} = point, board, frontier,
    explored_set, frontier_push, g, h, end_point, expanding) do
    points = [create_point(%{x: x+1, y: y}, board, g, h, end_point, point),
      create_point(%{x: x-1, y: y}, board, g, h, end_point, point),
      create_point(%{x: x, y: y+1}, board, g, h, end_point, point),
      create_point(%{x: x, y: y-1}, board, g, h, end_point, point)]
    |> Enum.shuffle()
    expanding.(frontier, Enum.at(points, 0), explored_set, frontier_push)
    |> expanding.(Enum.at(points, 1), explored_set, frontier_push)
    |> expanding.(Enum.at(points, 2), explored_set, frontier_push)
    |> expanding.(Enum.at(points, 3), explored_set, frontier_push)
  end

  def state_maker(board, %{x: x, y: y}) do
    board
    |> Enum.at(y)
    |> String.at(x)
  end

  def create_point(%{x: x, y: y} = point, board, _g, h, end_point, nil) do
    %{x: x, y: y, state: state_maker(board, point),
      parent: nil, path_cost: 0+h.({x, y}, end_point), level: 0}
  end
  def create_point(%{x: x, y: y} = point, board, g, h, end_point, %{path_cost: path_cost, level: level} = parent) do
    %{x: x, y: y, state: state_maker(board, point),
      parent: parent, path_cost: g.(path_cost, {x, y})+h.({x, y}, end_point), level: level+1}
  end

  @doc """
  `graph_search` function is base function for search on graphs for ai
  """
  def graph_search(
    frontier, explored_set,
    board, goal, wall, limit,
    frontier_pop, frontier_push
  )
  when
  is_list(frontier) and is_list(explored_set) and
  is_bitstring(goal) and is_bitstring(wall) and is_number(limit) and
  is_function(frontier_pop, 1) and is_function(frontier_push, 2)
    do
    graph_search(frontier, explored_set, {},
      board, goal, wall, limit,
      fn pc, _ -> pc+1 end, fn _, _ -> 0 end,
      frontier_pop, frontier_push
    )
  end

  def graph_search(
    frontier, explored_set, end_point,
    board, goal, wall, limit, g, h,
    frontier_pop, frontier_push, expander \\ &expander/4
  )
  when
  is_list(frontier) and is_list(explored_set) and is_tuple(end_point) and
  is_bitstring(goal) and is_bitstring(wall) and is_number(limit) and
  is_function(g, 2) and is_function(h, 2) and
  is_function(frontier_pop, 1) and is_function(frontier_push, 2)
    do

    {point, new_frontier} = frontier_pop.(frontier)
    new_explored_set = [point|explored_set]
    cond do
      point == nil ->
        [:error]
      point.state == goal ->
        [:ok, point, %{explored_set: new_explored_set}]
      point.level == limit ->
        [graph_search(new_frontier, new_explored_set, end_point,
            board, goal, wall, limit, g, h, frontier_pop, frontier_push), :cutoff]
      true ->
        expand(point, board, new_frontier, explored_set, frontier_push,
          g, h, end_point, expander)
          |> graph_search(new_explored_set, end_point,
        board, goal, wall, limit, g, h,frontier_pop, frontier_push)
    end
  end
end
