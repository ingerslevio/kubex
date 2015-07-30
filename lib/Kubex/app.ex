defmodule KubexApp do
  use Application

  def start(_type, _args) do
    Kubex.Supervisor.start_link
  end
end
