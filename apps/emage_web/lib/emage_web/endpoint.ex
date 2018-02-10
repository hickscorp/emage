defmodule EMage.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :emage_web

  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "No PORT environment variable set."
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end

  socket("/socket", EMage.Web.UserSocket)

  plug(
    Plug.Static,
    at: "/",
    from: :emage_web,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)
  )

  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, store: :cookie, key: "_emage_web_key", signing_salt: "xdd9Dz3f")
  plug(EMage.Web.Router)
end
