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
    {:error, "Visit Requests cannot be fulfilled by unregistered pals #{inspect(pal)}"}
  end
  def fulfill(%User{id: pal_id}, %Visit{member_id: pal_id}) do
    {:error, "A pal may not fulfill their own visit requests"}
  end
  def fulfill(%User{id: pal_id, email: email} = pal, %Visit{id: visit_id, member_id: member_id} = visit) do
    case Membership.login!(email) do
      %User{} ->
        case %Transaction{member_id: member_id, pal_id: pal_id, visit_id: visit_id} |> create_transaction() do
          {:ok, _} = positive ->
            member = User |> Repo.get(member_id)
            visit = Visit |> Repo.get(visit_id)
            apply_credits(visit, member, pal)
            positive
          negative ->
            negative
        end
      _ ->
        {:error, "Invalid pal email (not found), cannot fulfill #{inspect(visit)} by #{inspect(pal)}."}
    end
  end
  def fulfill(%User{id: pal_id, email: email} = pal, %{"id" => visit_id, "member_id" => member_id} = visit) do
    case Membership.login!(email) do
      %User{} ->
        case %Transaction{member_id: member_id, pal_id: pal_id, visit_id: visit_id} |> create_transaction() do
          {:ok, _} = positive ->
            member = User |> Repo.get(member_id)
            visit = Visit |> Repo.get(visit_id)
            apply_credits(visit, member, pal)
            positive
          negative ->
            negative
        end
      _ ->
        {:error, "Invalid pal email (not found), cannot fulfill #{inspect(visit)} by #{inspect(pal)}."}
    end
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

  defp apply_credits(visit, member, pal) do
    require Logger
    case Membership.credit(pal, visit) do
      {:error, message} = error ->
        Logger.error("Possible data integrity issue -> #{inspect(message)} cannot credit #{inspect(pal)} for visit #{inspect(visit)}")
        error
      ok -> ok
    end
    case Membership.debit(member, visit) do
      {:error, message} = error ->
        Logger.error("Possible data integrity issue -> #{inspect(message)} cannot debit #{inspect(member)} for visit #{inspect(visit)}")
        error
      ok -> ok
    end
  end

  defp create_transaction(transaction) do
    transaction
    |> Transaction.changeset()
    |> Repo.insert()
  end

  defp member_transactions(member_id) do
    from t in Transaction, where: t.member_id == ^member_id
  end

  defp pal_transactions(pal_id) do
    from t in Transaction, where: t.pal_id == ^pal_id
  end
end
