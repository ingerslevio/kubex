defmodule KubexTest do
  use Application

  def start(_type, _args) do
    # KubexTest.Supervisor.start_link

    :pg2.start()
    :pg2.create(:test_group)

    Plug.Adapters.Cowboy.http(KubexTest.Plug, [], port: get_port)

    {:ok, serverPid} = KubexTest.Server.start_link

    :pg2.join(:test_group, serverPid)

    {:ok, serverPid}
  end

  defp get_port do
    case System.get_env("PORT") do
      nil -> 4001
      portStr ->
        {port, _rest} = Integer.parse(portStr)
        port
    end
  end
end
