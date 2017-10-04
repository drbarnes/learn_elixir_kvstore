
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
    names = %{}
    refs = %{}   # References used to monitor bucket processes
    {:ok, {names, refs}}
  end


  def handle_call({:lookup, name}, _from, {names, refs}) do
    {:reply, Map.fetch(names, name), {names, refs}}
  end


  def handle_call({:create, name}, _from, {names, refs}) do
    if Map.has_key?(names, name) do
      {:reply, :error, {names, refs}}
    else
      {:ok, new_bucket} = KV.Bucket.start_link([])
      ref = Process.monitor(new_bucket)
      state_update = {Map.put(names, name, new_bucket), Map.put(refs, ref, name)}
      {:reply, {:ok, new_bucket}, state_update}
    end
  end


  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # Remove dead bucket from registry
    {name, refs} = Map.pop(refs, ref)
    IO.puts "bucket '#{name}' is dead and removed from registry"
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
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
