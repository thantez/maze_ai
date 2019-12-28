defmodule MazeServerWeb.MazeLive do
  use Phoenix.LiveView
  alias MazeServerWeb.MazeView

  def render(assigns), do: MazeView.render("index.html", assigns)

  def mount(_session, socket) do
    new_socket = socket
    |> assign(status: "init")
    |> assign(button_text: "start", event: "start")
    {:ok, new_socket}
  end

  def handle_event("start", _event, socket) do
    IO.inspect socket.assigns
    {:noreply, socket}
  end
end
