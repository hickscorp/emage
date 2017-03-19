use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :emage_web, EMage.Web.Endpoint,
  http: [port: 4001],
  server: false
