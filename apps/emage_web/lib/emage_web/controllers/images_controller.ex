defmodule EMage.Web.ImagesController do
  @moduledoc false

  use EMage.Web, :controller
  alias EMage.{Tokervisor, Future}
  alias EMage.Worker.{Downloader, Processor}

  plug :verify_token
  plug :spin_tokervisor

  defp verify_token(conn, _opts) do
    token = conn.params["token"]
    if Enum.member?(~w(tokena tokenb), token) do
      conn
        |> assign(:token, token)
    else
      conn
        |> put_resp_content_type("text/plain")
        |> send_resp(401, "Unauthorized")
        |> halt
    end
  end

  defp spin_tokervisor(conn, _opts) do
    conn
      |> assign(:tokervisor, Tokervisor.by conn.params["token"])
  end

  # Show an image.
  def show(conn, %{"token" => token, "url" => url, "stack" => stack}) do
    downloader = Downloader.by token, url
    processor = Processor.by token, downloader, url, stack
    case Future.result processor do
      {:ok, %{mime_type: m, output: o} = s} ->
        conn
          |> put_resp_content_type(m)
          |> send_resp(200, read(o))
      {:error, msg} when is_binary(msg) ->
        conn
          |> put_resp_content_type("text/plain")
          |> send_resp(500, "Error: #{msg}")
    end
  end

  @spec read(String.t) :: binary
  defp read(filename) do
    {:ok, file} = File.open filename, [:read]
    data = IO.binread file, :all
    File.close file
    data
  end
end
