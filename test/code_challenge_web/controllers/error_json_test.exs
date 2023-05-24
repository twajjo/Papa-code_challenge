defmodule CodeChallengeWeb.ErrorJSONTest do
  use CodeChallengeWeb.ConnCase, async: true

  test "renders 404" do
    assert CodeChallengeWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert CodeChallengeWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
