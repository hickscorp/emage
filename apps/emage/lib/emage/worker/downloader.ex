defmodule EMage.Worker.Downloader do
  @moduledoc """
  """

  alias EMage.Future

  @behaviour EMage.Future.Handler

  @type t :: pid

  @spec by(EMage.token, EMage.url) :: Downloader.t
  def by(token, url) do
    sup = {:via, Registry, {EMage.Registry.Tokens, {token, :downloads}}}
    {:ok, pid} = Supervisor.start_child sup, [token, url]
    pid
  end

  @spec result_by(EMage.token, EMage.url) :: {:ok, String.t} | {:error, String.t}
  def result_by(token, url) do
    {:ok, result} = token
      |> by(url)
      |> Future.result
    result
  end

  @spec start_link(EMage.token, EMage.url) :: {:ok, t}
  def start_link(token, url) do
    hash = EMage.hash url
    name = {:via, Registry, {:"EMage.Registry.Downloads.#{token}", hash}}
    case Future.start_link __MODULE__, {url, hash}, name: name do
      {:ok, _} = res -> res
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  @spec run({EMage.url, EMage.hash}) :: {:ok, EMage.filename}
  def run({url, hash}) do
    filename = "/tmp/emage/#{hash}"
    with {:ok, data} <- download(url),
         {:ok, file} <- open_file(filename),
         :ok <- write(file, data),
         :ok <- close(file) do
         {:ok, filename}
    else
      otherwise -> otherwise
    end
  end

  @spec download(EMage.url) :: {:ok, String.t} | {:error, String.t}
  def download(url) do
    case HTTPoison.get url do
      {:ok, %{body: data, status_code: sc}} ->
        case sc do
          200 ->
            {:ok, data}
          _ ->
            {:error, "Download failed because the response code was #{inspect sc}."}
        end
      _ ->
        {:error, "Download failed because of an transport failure."}
    end
  end

  @spec open_file(String.t) :: {:ok, File.t} | {:error, String.t}
  def open_file(filename) do
    case File.open filename, [:write] do
      {:ok, _} = res -> res
      _ -> {:error, "Download failed because the file cannot be opened."}
    end
  end

  @spec write(File.t, binary) :: :ok | {:error, String.t}
  def write(file, data) do
    case IO.binwrite file, data do
      :ok -> :ok
      _ -> {:error, "Download failed because the file cannot be written."}
    end
  end

  @spec close(File.t) :: :ok | {:error, String.t}
  def close(file) do
    case File.close file do
      :ok -> :ok
      _ -> {:error, "Unable to close the download file."}
    end
  end
end
