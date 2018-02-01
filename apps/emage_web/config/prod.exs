use Mix.Config

config :emage_web, EMage.Web.Endpoint,
  load_from_system_env: true,
  url: [host: "the.emage.run", port: 4000],
  server: true

import_config "prod.secret.exs"
