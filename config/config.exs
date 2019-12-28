# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :maze_server, MazeServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XBw9P5Dk1WKt0cD8qipvJ9PAmhdxh1NaezGhP6LUT81qKOwaA4VZ40CWaDl0nvXE",
  render_errors: [view: MazeServerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MazeServer.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "fAblvFgaqb9lZPw2aHmq0mVYMW2ZQlNX"
  ]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
