
defmodule KV.BucketRegistry do
  use GenServer

  #
  # Client API
  #

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.
  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end


  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end


  #
  # Server Callbacks
  #
  def init(:ok) do
    {:ok, %{}}
  end


  def handle_call({:lookup, name}, _from, buckets) do
    {:reply, Map.fetch(buckets, name), buckets}
  end


  def handle_call({:create, name}, _from, buckets) do
    if Map.has_key?(buckets, name) do
      {:reply, :error, buckets}
    else
      new_bucket = KV.Bucket.start_link([])
      {:reply, new_bucket, Map.put(buckets, name, new_bucket)}
    end
  end

  # What Create would look like as an async/fire-and-forget cast
  # def handle_cast({:create, name}, _from, buckets) do
  #   if Map.has_key?(buckets, name) do
  #     {:noreply, buckets}
  #   else
  #     new_bucket = KV.Bucket.start_link([])
  #     {:noreply, Map.put(buckets, name, new_bucket)}
  #   end
  # end
end
