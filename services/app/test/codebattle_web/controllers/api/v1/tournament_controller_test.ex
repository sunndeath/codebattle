defmodule CodebattleWeb.Api.V1.TournamentControllerTest do
  use CodebattleWeb.ConnCase, async: true

  test "show tournament aggregate", %{conn: conn} do
    conn =
      conn
      |> get(api_v1_tournament_path(conn, :show, 1))

    assert Enum.count(json_response(conn, 200)["users"]) == 32
  end
end
