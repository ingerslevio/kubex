defmodule KubexApp do
  use Application

  def start(_type, _args) do
    supervisor = Kubex.Supervisor.start_link
    setup_default_pinger Enum.into(Application.get_env(:kubex, Kubex.Pinger, enable: false), %{})
    supervisor
  end

  def start() do
    start(nil,nil)
  end

  defp setup_default_pinger(nil) do
  end
  defp setup_default_pinger(%{enable: false}) do
  end
  defp setup_default_pinger(config) do
    query = case config[:server] do
      nil -> Kubex.server_from_environment
    end
    if not is_nil(config[:label_selector]), do: query = Kubex.query query, :label_selector, config[:label_selector]
    Kubex.start_pinger query, :default
  end
end
