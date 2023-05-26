defmodule CodeChallenge.Domain.Request.Impl do
  @moduledoc false
  require CodeChallenge.Domain.Request.API
  @behaviour CodeChallenge.Domain.Request.API

  alias CodeChallenge.Schema.{Transaction, User, Visit}
  alias CodeChallenge.Domain.Membership
  alias CodeChallenge.Repo

  import Ecto.Query

  @impl true
  def fulfilled(%User{id: nil} = pal), do: {:error, "Cannot provide fulfilled requests by an unregistered pal #{inspect(pal)}."}
  def fulfilled(%User{id: pal_id, email: email}) do
    case Membership.login(email) do
      {:ok, _} ->
        {
          :ok,
          from(v in Visit, join: t in Transaction,
            on: t.pal_id == ^pal_id and v.id == t.visit_id)
          |> Repo.all(preload: [:member, :transactions])
        }
      bad_news ->
        bad_news
    end
  end

  @impl true
  def fulfilled!() do
    from(v in Visit, join: t in Transaction, on: v.id == t.view_id)
    |> Repo.all(preload: [:member, :transactions])
  end

  @impl true
  def available(%User{id: nil} = pal) do
    {:error, "Cannot provide available requests for an unregistered pal #{inspect(pal)}."}
  end
  def available(%User{id: pal_id, email: email} = _pal) do
    case Membership.login(email) do
      {:ok, _} ->
        from(v in Visit, as: :visit, where: v.member_id != ^pal_id and not exists(from t in Transaction, where: t.visit_id == parent_as(:visit).id))
        |> Repo.all(preload: [:member])
      bad_news ->
        bad_news
    end
  end

  @impl true
  def available!() do
    from(v in Visit, as: :visit, where: not exists(from t in Transaction, where: t.visit_id == parent_as(:visit).id))
    |> Repo.all(preload: [:member])
  end

  @impl true
  def outstanding(%User{id: nil} = member) do
    {:error, "Cannot provide outstanding requests for an unregistered member #{inspect(member)}."}
  end
  def outstanding(%User{id: member_id, email: email}) do
    case Membership.login(email) do
      {:ok, _} ->
        from(v in Visit, where: v.member_id == ^member_id)
        |> Repo.all(preload: [:member])
      bad_news ->
        bad_news
    end
  end

  @impl true
  def make(%User{id: nil} = member, _) do
    {:error, "Cannot provide outstanding requests for an unregistered member #{inspect(member)}."}
  end
  def make(%User{email: email, credits: credits} = member, %{date: _date, minutes: minutes} = details) do
    case Membership.login(email) do
      {:ok, _} ->
        if credits < minutes do
          {:error, "Cannot make #{inspect(minutes)} Visit Request for member #{inspect(member)}, not enough credits."}
        else
          new_visit(member, details)
        end
      bad_news ->
        bad_news
    end
  end
  def make(%User{email: email, credits: credits} = member, %{"date" => _date, "minutes" => minutes} = details) do
    case Membership.login(email) do
      {:ok, _} ->
        if credits < minutes do
          {:error, "Cannot make #{inspect(minutes)} Visit Request for member #{inspect(member)}, not enough credits."}
        else
          new_visit(member, details)
        end
      bad_news ->
        bad_news
    end
  end

  # Privates

  defp new_visit(%User{id: member_id}, %{date: date, minutes: minutes, tasks: tasks}) do
    %Visit{member_id: member_id, date: date, minutes: minutes, tasks: tasks}
    |> Visit.changeset()
    |> Repo.insert(preload: [:member])
  end
  defp new_visit(%User{id: member_id}, %{date: date, minutes: minutes}) do
    %Visit{member_id: member_id, date: date, minutes: minutes}
    |> Visit.changeset()
    |> Repo.insert(preload: [:member])
  end
end
