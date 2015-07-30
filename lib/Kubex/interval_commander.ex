defmodule Kubex.IntervalCommander do
  use GenServer

  def start_link(receiver, command, time, opts \\ []) do
    GenServer.start_link(__MODULE__, {receiver, command, time}, opts)
  end

  def init({receiver, command, time}) do
    Process.send_after(self, :interval, time)
    {:ok, {receiver, command, time}}
  end

  def handle_info(:interval, {receiver, command, time} = state) do
    GenServer.call(receiver, command)
    Process.send_after(self, :interval, time)
    {:noreply, state}
  end
  def handle_info(_, state) do
    {:noreply, state}
  end
end
