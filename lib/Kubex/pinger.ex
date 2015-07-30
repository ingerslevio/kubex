defmodule Kubex.Pinger do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(_) do
    {:ok, %{data: HashDict.new(), events: GenEvent.start_link()}}
  end

  def add_query(pid, id, query) do
    GenServer.call(pid, {:start_pinger, id, query})
  end

  def get_results(pid, id) do
    GenServer.call(pid, {:get_results, id})
  end

  def handle_call({:start_pinger, id, query}, _from, %{data: data} = state) do
    data = HashDict.put(data, id, {query, HashDict.new()})
    Kubex.IntervalCommander.start_link(self, {:ping, id}, 1000)
    {:reply, :ok, %{state | data: data}}
  end

  def handle_call({:ping, id}, _from, %{data: data} = state) do
    {query, _} = HashDict.get(data, id)

    results = query
    |> Kubex.get_pods
    |> Enum.map(&(String.to_atom("app@" <> &1["status"]["podIP"])))
    |> Enum.map(fn (node) -> {node, Node.ping(node)} end)
    data = HashDict.put(data, id, {query, results})
    # GenEvent.sync_notify(event, {:pinged, id, results})

    {:reply, results, %{state | data: data}}
  end

  def handle_call({:get_results, id}, _from, %{data: data} = state) do
    {_, results} = HashDict.get(data, id)
    {:reply, results, state}
  end
end
