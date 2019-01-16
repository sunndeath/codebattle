defmodule Codebattle.Bot.RecorderServer do
  @moduledoc "Gen server for calculating bot diffs and store it to database after player won the game"

  use GenServer
  require Logger

  alias Codebattle.Repo
  alias Codebattle.Bot.Playbook

  # API
  def start_link(game_id, task_id) do
    GenServer.start_link(__MODULE__, [game_id, task_id], name: server_name(game_id))
  end

  def update_text(game_id, player_id, text) do
    try do
      GenServer.cast(server_name(game_id), {:update_text, player_id, text})
    rescue
      e in FunctionClauseError -> e
    end
  end

  def update_lang(game_id, player_id, lang) do
    try do
      GenServer.cast(server_name(game_id), {:update_lang, player_id, lang})
    rescue
      e in FunctionClauseError -> e
    end
  end

  def add_player(game_id, player_id) do
    try do
      GenServer.call(server_name(game_id), {:add_player, player_id})
    rescue
      e in FunctionClauseError -> e
    end
  end

  def store(game_id, player_id) do
    try do
      GenServer.cast(server_name(game_id), {:store, player_id})
    rescue
      e in FunctionClauseError -> e
    end
  end

  def recorder_pid(game_id) do
    :gproc.where(recorder_key(game_id))
  end

  # SERVER
  def init([game_id, task_id]) do
    Logger.info("Start bot recorder server for task_id: #{task_id}, game_id: #{game_id}")

    {:ok,
     %{
       game_id: game_id,
       task_id: task_id,
       data: %{}
     }}
  end

  def handle_cast({:update_text, player_id, text}, state) do
    Logger.debug(
      "#{__MODULE__} CAST update_text TEXT: #{inspect(text)}, STATE: #{inspect(state)}"
    )

    time = state.time || NaiveDateTime.utc_now()
    new_time = NaiveDateTime.utc_now()
    new_delta = TextDelta.new() |> TextDelta.insert(text)

    diff = %{
      delta: TextDelta.diff!(state.delta, new_delta).ops,
      time: NaiveDateTime.diff(new_time, time, :millisecond)
    }

    new_state = %{state | delta: new_delta, diff: [diff | state.diff], time: new_time}

    {:noreply, new_state}
  end

  def handle_cast({:update_lang, player_id, lang}, state) do
    Logger.debug(
      "#{__MODULE__} CAST update_lang LANG: #{inspect(lang)}, STATE: #{inspect(state)}"
    )

    time = state.time || NaiveDateTime.utc_now()
    new_time = NaiveDateTime.utc_now()

    diff = %{
      lang: lang,
      time: NaiveDateTime.diff(new_time, time, :millisecond)
    }

    new_state = %{state | lang: lang, diff: [diff | state.diff], time: new_time}

    {:noreply, new_state}
  end

  def handle_call({:add_player, player_id}, _from, state) do
    Logger.debug(
      "#{__MODULE__} CALL add_player player_id: #{inspect(player_id)}, STATE: #{inspect(state)}"
    )

    new_data =
      state.data
      |> Map.merge(%{
        player_id => %{
          player_id: player_id,
          delta: TextDelta.new([]),
          lang: :js,
          time: nil,
          # Array of diffs to db playbook
          diff: []
        }
      })

    new_state = %{state | data: new_data}
    {:reply, new_state, new_state}
  end

  def handle_cast({:store, player_id}, state) do
    Logger.info("Store bot_playbook for
      task_id: #{state.task_id},
      game_id: #{state.game_id},
      player_id: #{state.player_id}")

    if state.player_id != 0 do
      %Playbook{
        data: %{playbook: state.diff |> Enum.reverse()},
        lang: to_string(state.lang),
        task_id: state.task_id,
        player_id: state.player_id,
        game_id: state.game_id |> to_string |> Integer.parse() |> elem(0)
      }
      |> Repo.insert()
    end

    {:stop, :normal, state}
  end

  # HELPERS
  defp server_name(game_id) do
    {:via, :gproc, recorder_key(game_id)}
  end

  defp recorder_key(game_id) do
    key = to_charlist(game_id)
    {:n, :l, {:bot_recorder, key}}
  end
end
