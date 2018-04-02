defmodule ExWallet.Storage.Disk do
  @directory_path ".keys"
  @file_name "key"

  def write(private_key, public_key, directory \\ @directory_path, file \\ @file_name) do
    with file_path = Path.join(directory, file),
         :ok <- maybe_create_directory(directory),
         :ok <- File.write(file_path, private_key),
         :ok <- File.write("#{file_path}.pub", public_key) do
      file_path
    else
      {:error, error} -> translate(error)
    end
  end

  def read(directory \\ @directory_path, file \\ @file_name) do
    with file_path = Path.join(directory, file),
         {:ok, private_key} <- File.read(file_path),
         {:ok, public_key} <- File.read("#{file_path}.pub") do
      {private_key, public_key}
    else
      {:error, error} -> translate(error)
    end
  end

  def clear(directory \\ @directory_path) do
    with {:ok, files} <- File.rm_rf(directory) do
      files
    else
      {:error, error} -> translate(error)
    end
  end

  defp maybe_create_directory(directory), do: File.mkdir_p(directory)

  defp translate(error), do: :file.format_error(error)
end
