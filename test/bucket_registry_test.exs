
defmodule BucketRegistryTest do
  use ExUnit.Case
  alias KV.BucketRegistry, as: Registry

  setup do
    {:ok, registry} = start_supervised(Registry)
    %{registry: registry}
  end


  test "create", %{registry: registry} do
    assert Registry.lookup(registry, "test") == :error

    bucket = case Registry.create(registry, "test") do
      {:ok, b} -> b
      :error -> flunk "Error creating new bucket"
    end

    case Registry.lookup(registry, "test") do
      {:ok, b} -> assert b == bucket
      :error -> flunk "Looked up bucket doesn't match created"
    end
  end

end
