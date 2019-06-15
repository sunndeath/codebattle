defmodule CodebattleWeb.Api.V1.TournamentController do
  use CodebattleWeb, :controller

  alias Codebattle.{Repo, User}
  import Ecto.Query, only: [from: 2]

  def show(conn, %{}) do
    query = from(u in User, limit: 1)

    user = Repo.one(query)
    json(conn, %{users: List.duplicate(user, 32)})
  end
end
