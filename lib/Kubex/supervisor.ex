defmodule Kubex.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @kubex_pinger_name Kubex.Pinger

  def init(:ok) do
    children = [
      worker(Kubex.Pinger, [[name: @kubex_pinger_name]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
