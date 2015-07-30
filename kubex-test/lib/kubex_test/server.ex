defmodule KubexTest.Server do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(_) do
    {:ok, :ok}
  end

  def get_node_name(pid) do
    GenServer.call(pid, {:get_node_name})
  end

  def handle_call({:get_node_name}, _from, state) do
    {:reply, Node.self, state}
  end
end
