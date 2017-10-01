
defmodule BucketTest do
  use ExUnit.Case

  setup do
    {:ok, bucket} = start_supervised(KV.Bucket)
    %{bucket: bucket}
  end

  test "non existent key returns null", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "blah") == nil
  end

  test "normal behavior", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "test") == nil
    KV.Bucket.put(bucket, "test", 3)
    assert KV.Bucket.get(bucket, "test") == 3
  end

  test "delete", %{bucket: bucket} do
    KV.Bucket.put(bucket, "test", 3)
    assert KV.Bucket.get(bucket, "test") == 3
    KV.Bucket.delete(bucket, "test")
    assert KV.Bucket.get(bucket, "test") == nil 
  end
end
