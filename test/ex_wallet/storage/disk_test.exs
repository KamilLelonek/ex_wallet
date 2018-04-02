defmodule ExWallet.Storage.DiskTest do
  use ExUnit.Case, async: true

  alias ExWallet.Storage.Disk

  @directory_path ".keys"
  @file_name "key"
  @file_path_private "#{@directory_path}/#{@file_name}"
  @file_path_public "#{@file_path_private}.pub"
  @private_key "18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725"
  @public_key "0450863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B23522CD470243453A299FA9E77237716103ABC11A1DF38855ED6F2EE187E9C582BA6"

  defp clear_artifacts, do: File.rm_rf!(@directory_path)

  setup do
    on_exit(&clear_artifacts/0)
    :ok
  end

  describe "write " do
    test "should not write keys in the root directory" do
      assert 'permission denied' = Disk.write(@private_key, @public_key, "/")
    end

    test "should not write keys with invalid name" do
      assert 'illegal operation on a directory' =
               Disk.write(@private_key, @public_key, @directory_path, "/")
    end

    test "should not write keys in an invalid directory" do
      assert 'no such file or directory' = Disk.write(@private_key, @public_key, "", "")
    end

    test "should write public and private keys" do
      assert @file_path_private =
               Disk.write(@private_key, @public_key, @directory_path, @file_name)
    end
  end

  describe "read" do
    test "should not read from an invalid directory" do
      assert 'illegal operation on a directory' = Disk.read("/", "/")
    end

    test "should not read a nonexistent directory" do
      assert 'no such file or directory' = Disk.read("/directory")
    end

    test "should not read a nonexistent file" do
      assert 'no such file or directory' = Disk.read("/", "file")
    end

    test "should read public and private keys" do
      Disk.write(@private_key, @public_key, @directory_path, @file_name)

      assert {@private_key, @public_key} = Disk.read(@directory_path, @file_name)
    end
  end

  describe "clear" do
    test "should remove stored files" do
      Disk.write(@private_key, @public_key, @directory_path)

      assert {_, _} = Disk.read(@directory_path)

      assert [@directory_path, @file_path_public, @file_path_private] =
               Disk.clear(@directory_path)

      assert 'no such file or directory' = Disk.read(@directory_path)
    end
  end
end
