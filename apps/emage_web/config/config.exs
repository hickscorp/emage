use Mix.Config

config :emage_web,
  namespace: EMage.Web

config :emage_web, EMage.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "Zno9zhUikACud4ajlf+mrMz7xdgk4jjT+wdtytFhCPZOp978Iiboz3HBKFzKREO+",
  render_errors: [view: EMage.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EMage.Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :wobserver,
  mode: :plug,
  remote_url_prefix: "/wobserver"

import_config "#{Mix.env}.exs"
