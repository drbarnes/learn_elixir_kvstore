
defmodule KV do
  use Application

  def start(_type, _args) do
    KV.Supervisor.start_link(name: :supervisor)
  end
end
