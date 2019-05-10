defmodule SFTPClient.Operations.UploadFile do
  alias SFTPClient.Conn
  alias SFTPClient.ConnError
  alias SFTPClient.InvalidOptionError
  alias SFTPClient.OperationError

  @doc """
  Uploads a file from the file system to the server.
  """
  @spec upload_file(Conn.t(), String.t(), String.t()) ::
          {:ok, String.t()} | {:error, any}
  def upload_file(%Conn{} = conn, local_path, remote_path) do
    {:ok, upload_file!(conn, local_path, remote_path)}
  rescue
    error in [ConnError, InvalidOptionError, OperationError] ->
      {:error, error}
  end

  @doc """
  Uploads a file from the file system to the server.Raises when the operation
  fails.
  """
  @spec upload_file!(Conn.t(), String.t(), String.t()) :: String.t() | no_return
  def upload_file!(%Conn{} = conn, local_path, remote_path) do
    source_stream = File.stream!(local_path)
    target_stream = SFTPClient.stream_file!(conn, remote_path)

    source_stream
    |> Stream.into(target_stream)
    |> Stream.run()

    remote_path
  end
end
