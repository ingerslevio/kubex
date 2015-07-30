defmodule KubexTest.Plug do
  import Plug.Conn

  def init(_options) do
  end

  def call(conn, _opts) do
    members = :pg2.get_members(:test_group)
    |> Enum.map( &(KubexTest.Server.get_node_name(&1)) )

    pings = Kubex.Pinger.get_results(Kubex.Pinger, :pinger)
    |> Enum.map(fn {node, ping} -> %{node: node, ping: ping} end)

    conn
    |> put_resp_content_type("text/json")
    |> send_resp(200, Poison.encode!( %{
      self: Node.self,
      members: members,
      pings: pings
    } ))
  end
end
