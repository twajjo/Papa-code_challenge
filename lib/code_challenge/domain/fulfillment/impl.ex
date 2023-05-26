defmodule CodeChallenge.Domain.Fulfillment.Impl do
  @moduledoc false
  require CodeChallenge.Domain.Fulfillment.API
  @behaviour CodeChallenge.Domain.Fulfillment.API

  alias CodeChallenge.Schema.{Transaction, User, Visit}
  alias CodeChallenge.Repo
  alias CodeChallenge.Domain.Membership

  import Ecto.Query

  @impl true
  def fulfill(%User{id: nil} = pal, %Visit{}) do
    {:error, "Unregistered users cannot fulfill Visit Requests #{inspect(pal)}"}
  end
  def fulfill(%User{id: pal_id}, %Visit{member_id: pal_id}) do
    {:error, "A pal may not fulfill their own visit requests"}
  end
  def fulfill(%User{id: pal_id, email: email}, %Visit{id: visit_id, member_id: member_id}) do
    case Membership.login(email) do
      {:ok, _} ->
        %Transaction{member_id: member_id, pal_id: pal_id, visit_id: visit_id}
        |> Transaction.changeset()
      bad_news ->
        bad_news
    end
  end
  def fulfill(%User{id: pal_id}, %{"id" => visit_id, "member_id" => member_id}) do
    {:ok, %Transaction{member_id: member_id, pal_id: pal_id, visit_id: visit_id}}
  end

  @impl true
  def fulfilled!() do
    Transaction
    |> Repo.all()
  end

  @impl true
  def fulfilled_by_pal!(%User{id: pal_id}) do
    pal_id
    |> pal_transactions()
    |> Repo.all()
  end

  @impl true
  def fulfilled_for_member!(%User{id: member_id}) do
    member_id
    |> member_transactions()
    |> Repo.all()
  end

  # Privates

  defp member_transactions(member_id) do
    from t in Transaction, where: t.member_id == ^member_id
  end

  defp pal_transactions(pal_id) do
    from t in Transaction, where: t.pal_id == ^pal_id
  end
end
