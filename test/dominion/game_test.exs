defmodule Dominion.GameTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, game} = Dominion.Game.start_link
    {:ok, game: game}
  end

  test "should return a game with no players", %{game: game} do
    assert Dominion.Game.players(game) == %{}
  end

  test "can add a player", %{game: game} do
    {:ok, player} = Dominion.Game.add_player(game, "Michael")

    assert Dominion.Game.players(game) == %{"Michael" => player}
  end

  test "needs at least 2 players", %{game: game} do
    {:ok, _} = Dominion.Game.add_player(game, "Michael")

    assert Dominion.Game.ready?(game) == false
  end

  test "can't have two players named the same thing", %{game: game} do
    {:ok, _} = Dominion.Game.add_player(game, "Michael")

    assert {:error, :duplicate_name} = Dominion.Game.add_player(game, "Michael")
  end

  test "can have up to 4 players", %{game: game} do
    {:ok, _} = Dominion.Game.add_player(game, "Michael")
    {:ok, _} = Dominion.Game.add_player(game, "Lauren")

    assert Dominion.Game.ready?(game) == true

    {:ok, _} = Dominion.Game.add_player(game, "Howard")

    assert Dominion.Game.ready?(game) == true

    {:ok, _} = Dominion.Game.add_player(game, "Jessi")

    assert Dominion.Game.ready?(game) == true
  end

  test "cannot have more than 4 players", %{game: game} do
    {:ok, _} = Dominion.Game.add_player(game, "Michael")
    {:ok, _} = Dominion.Game.add_player(game, "Lauren")
    {:ok, _} = Dominion.Game.add_player(game, "Howard")
    {:ok, _} = Dominion.Game.add_player(game, "Jessi")

    assert {:error, :game_alredy_started} = Dominion.Game.add_player(game, "Ennis")
  end

  test "cannot start a game with the wrong number of players", %{game: game} do
    {:ok, _} = Dominion.Game.add_player(game, "Michael")

    assert {:error, :not_enough_players} = Dominion.Game.start(game)
  end

  test "can start a game with the correct number of players", %{game: game} do
    {:ok, _} = Dominion.Game.add_player(game, "Michael")
    {:ok, _} = Dominion.Game.add_player(game, "Lauren")

    assert {:ok, _} = Dominion.Game.start(game)
  end

  test "cannot add a player to a started game", %{game: game} do
    {:ok, _} = Dominion.Game.add_player(game, "Michael")
    {:ok, _} = Dominion.Game.add_player(game, "Lauren")
    {:ok, _} = Dominion.Game.add_player(game, "Howard")

    assert {:ok, _} = Dominion.Game.start(game)

    assert {:error, :game_alredy_started} = Dominion.Game.add_player(game, "Jessi")
  end
end
