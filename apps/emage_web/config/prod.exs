use Mix.Config

config :emage_web, EMage.Web.Endpoint,
  on_init: {EMage.Web.Endpoint, :load_from_system_env, []},
  url: [host: "emage.run", port: 80],
  # cache_static_manifest: "priv/static/cache_manifest.json"
  server: true

import_config "prod.secret.exs"
