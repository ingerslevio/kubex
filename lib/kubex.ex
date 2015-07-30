defmodule Kubex do

  def server(address, username, password) do
    %{
      server: {address, username, password},
      label_selector: nil,
      type: nil
    }
  end

  def server_from_environment(username, password) do
    Kubex.server( "https://" <> System.get_env("KUBERNETES_SERVICE_HOST") <> ":" <> System.get_env("KUBERNETES_SERVICE_PORT"), username, password )
  end

  def query(query, :label_selector, label_selector) do
    %{query | label_selector: label_selector}
  end

  def get_pods(query) do
    %{query | type: :pods}
    |> execute_get
  end

  def execute_get(%{server: server} = query) do
    url = generate_url query
    result = get(server, url)
    result["items"]
  end

  defp generate_url(query) do
    %{type: type, label_selector: label_selector} = query
    args = []
    if label_selector != nil do
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

end
