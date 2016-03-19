defmodule Dominion.Player do
  use GenServer

  ## API

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  ## Callbacks

  def init(name) do
    {:ok, {name}}
  end
end
