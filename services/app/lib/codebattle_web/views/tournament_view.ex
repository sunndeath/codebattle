defmodule CodebattleWeb.TournamentView do
  use CodebattleWeb, :view

  def csrf_token() do
    Plug.CSRFProtection.get_csrf_token()
  end
end
