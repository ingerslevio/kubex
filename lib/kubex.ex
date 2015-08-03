defmodule Kubex do

  def server(address, username, password, query \\ nil) do
    %{ ensure_query(query) | server: {address, username, password} }
  end

  def server_from_environment(username \\ nil, password \\ nil, query \\ nil) do
    env_server = Application.get_env(:kubex, :server)
    address = case env_server[:address] do
      nil -> "https://" <> System.get_env("KUBERNETES_SERVICE_HOST") <> ":" <> System.get_env("KUBERNETES_SERVICE_PORT")
      address -> address
    end
    case {username, password, env_server[:username], env_server[:password]} do
      {nil, nil, nil, nil} -> Kubex.server(address, "no", "user", query)
      {u, p, _, _} when not is_nil(u) and not is_nil(p) -> Kubex.server(address, u, p, query)
      {_, _, u, p} when not is_nil(u) and not is_nil(p) -> Kubex.server(address, u, p, query)
    end
  end

  def query(:label_selector, label_selector) do
    query(nil, :label_selector, label_selector)
  end

  def query(q, :label_selector, label_selector) do
    %{ensure_query(q) | label_selector: label_selector}
  end

  def get_pods(q \\ nil) do
    %{ensure_query(q) | type: :pods}
    |> execute_get
  end

  def execute_get(query) do
    if is_nil(query.server), do: query = server_from_environment(nil,nil,query)

    url = generate_url query
    result = get(query.server, url)
    result["items"]
  end

  defp generate_url(%Kubex.Query{} = query) do
    %Kubex.Query{type: type, label_selector: label_selector} = query
    args = []
    if not is_nil(label_selector) do
      args = args ++ ["labelSelector=#{label_selector}"]
    end
    base = case type do
      :pods -> "pods"
    end
    "#{base}?#{Enum.join(args, "&")}"
  end

  defp get({address, username, password}, url) do
    auth = Base.encode64("#{username}:#{password}")
    %HTTPoison.Response{ body: result } = HTTPoison.get! "#{address}/api/v1/#{url}", [{:Authorization, "Basic #{auth}"}], hackney: [insecure: true]
    Poison.decode! result
  end

  def start_pinger(query, id) do
     Kubex.Pinger.add_query(Kubex.Pinger, id, query)
  end

  defp ensure_query(nil) do
    %Kubex.Query{}
  end
  defp ensure_query(%Kubex.Query{} = q) do
    q
  end

end
