defmodule QueryTest do
  use ExUnit.Case

  defmodule QueryTest.Plug do
    import Plug.Conn

    def init(options) do
      options
    end

    def call(conn, {result, agent}) do
      Agent.update(agent, fn list -> [conn | list] end)
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Poison.encode!(result))
    end
  end

  setup_all do
    {:ok, _} = :application.ensure_all_started(:cowboy)
    :ok
  end

  defp mock_server(result) do
    {:ok, pid} = Agent.start_link(fn -> [] end)
    port = start_mock_server({QueryTest.Plug, {result, pid}, 50000})
    on_exit(fn -> Plug.Adapters.Cowboy.shutdown(QueryTest.Plug.HTTP) end)
    {port, pid}
  end

  defp start_mock_server({plug, data, port}) do
    case Plug.Adapters.Cowboy.http(plug, data, port: port) do
      {:error, :eaddrinuse} -> start_mock_server({plug, data, port + 1})
      {:ok, _pid} -> port
    end
  end

  defp get_request({_port, agent_pid}) do
    Agent.get agent_pid, fn [req] -> req end
  end

  defp get_server_address({port, _agent_pid}) do
    "http://localhost:#{port}"
  end

  test "can query pods with server setup explictly" do
    serv = mock_server(%{items: []})
    pods = Kubex.server(get_server_address(serv), "any", "user")
    |> Kubex.get_pods

    assert pods == []
    assert get_request(serv).request_path == "/api/v1/pods"
  end

  test "can query pods with server setup from app environment" do
    serv = mock_server(%{items: []})
    on_exit(fn -> Application.put_env(:kubex, :server, nil) end)
    Application.put_env(:kubex, :server, address: get_server_address(serv))

    pods = Kubex.get_pods

    assert pods == []
    assert get_request(serv).request_path == "/api/v1/pods"
  end

  test "can query pods with label_selector with server setup from app environment" do
    serv = mock_server(%{items: []})
    on_exit(fn -> Application.put_env(:kubex, :server, nil) end)
    Application.put_env(:kubex, :server, address: get_server_address(serv))


    pods = Kubex.query(:label_selector, "my=label")
    |> Kubex.get_pods

    assert pods == []
    assert get_request(serv).request_path == "/api/v1/pods"
    assert get_request(serv).query_string == "labelSelector=my=label"
  end

  test "can query pods with server, username & password setup from app environment" do
    serv = mock_server(%{items: []})
    on_exit(fn -> Application.put_env(:kubex, :server, nil) end)
    Application.put_env(:kubex, :server, address: get_server_address(serv),
                                         username: "myuser",
                                         password: "mypassword")

    Kubex.get_pods

    "Basic " <> auth = get_request_header(serv, "authorization")
    assert String.split(Base.decode64!(auth), ":") == ["myuser", "mypassword"]
  end

  test "can query pods with server setup from app environment, but username & password set explicitly" do
    serv = mock_server(%{items: []})
    on_exit(fn -> Application.put_env(:kubex, :server, nil) end)
    Application.put_env(:kubex, :server, address: get_server_address(serv))

    Kubex.server_from_environment("user1", "thepass")
    |> Kubex.get_pods

    "Basic " <> auth = get_request_header(serv, "authorization")
    assert String.split(Base.decode64!(auth), ":") == ["user1", "thepass"]
  end

  defp get_request_header(serv, key) do
    get_request(serv).req_headers
    |> Enum.filter(fn({k, _}) -> k == key end)
    |> hd
    |> elem(1)
  end
end
