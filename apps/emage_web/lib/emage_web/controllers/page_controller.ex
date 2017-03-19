defmodule EMage.Web.PageController do
  use EMage.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
