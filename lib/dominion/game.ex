defmodule Dominion.Game do
  use GenServer

  ## API

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def players(game) do
    GenServer.call(game, :list_players)
  end

  def add_player(game, name) do
    GenServer.call(game, {:add_player, name})
  end

  def ready?(game) do
    GenServer.call(game, :ready?)
  end

  ## Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call(:list_players, _from, players) do
    {:reply, players, players}
  end

  def handle_call({:add_player, name}, _from, players) do
    case Enum.count(players) do
      4 ->
        {:reply, {:error, :too_many_players}, players}
      _ ->
        case Map.fetch(players, name) do
          {:ok, _} ->
            {:reply, {:error, :duplicate_name}, players}
          :error ->
            {:ok, player} = Dominion.Player.start_link(name)
            {:reply, {:ok, player}, Map.put(players, name, player)}
        end
    end
  end

  def handle_call(:ready?, _from, players) do
    player_count = Enum.count(players)
    cond do
      player_count < 2 or player_count > 4 -> {:reply, false, players}
      true -> {:reply, true, players}
    end
  end
end
