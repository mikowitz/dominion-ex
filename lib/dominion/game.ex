defmodule Dominion.Game do
  use GenServer

  defmodule State do
    defstruct started: false, players: %{}
  end

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

  def start(game) do
    GenServer.call(game, :start)
  end

  def started?(game) do
    GenServer.call(game, :started?)
  end

  ## Callbacks

  def init(:ok) do
    # {:ok, [started?: false, players: %{}]}
    {:ok, %Dominion.Game.State{}}
  end

  def handle_call(:list_players, _from, %{players: players} = state) do
    {:reply, players, state}
  end

  def handle_call({:add_player, name}, _from, %{players: players, started: started} = state) do
    case started do
      true -> {:reply, {:error, :game_alredy_started}, state}
      _ ->
        case Enum.count(players) do
          4 ->
            {:reply, {:error, :too_many_players}, state}
          _ ->
            case Map.fetch(players, name) do
              {:ok, _} ->
                {:reply, {:error, :duplicate_name}, state}
              _ ->
                {:ok, player} = Dominion.Player.start_link(name)
                new_players = Map.put(players, name, player)
                case Enum.count(new_players) do
                  4 ->
                    new_started = true
                  _ ->
                    new_started = started
                end
                new_state = %{players: new_players, started: new_started}
                {:reply, {:ok, player}, new_state}
            end
        end
    end
  end

  def handle_call(:ready?, _from, %{players: players} = state) do
    {:reply, enough_players?(players), state}
  end

  def handle_call(:start, _from, %{players: players} = state) do
    case enough_players?(players) do
      false ->
        {:reply, {:error, :not_enough_players}, state}
      true ->
        {:reply, {:ok, players}, %{state | started: true }}
    end
  end

  def handle_call(:started?, _from, %{started: started} = state) do
    {:ok, started, state}
  end

  ## Helpers

  def enough_players?(players) do
    player_count = Enum.count(players)
    cond do
      player_count < 2 or player_count > 4 -> false
      true -> true
    end
  end

end
