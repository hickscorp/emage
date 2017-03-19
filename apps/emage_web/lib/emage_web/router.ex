defmodule EMage.Web.Router do
  @moduledoc false

  use EMage.Web, :router

  pipeline :images do
    plug :accepts, ~w(*)
  end
  scope "/i", EMage.Web do
    pipe_through :images
    get "/:token/v1/:url/*stack", ImagesController, :show
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end
  scope "/api", EMage.Web do
    pipe_through :api
  end

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
  scope "/", EMage.Web do
    pipe_through :browser
    get "/", PageController, :index
  end

  # forward "/wobserver", Wobserver.Web.Router
end
