defmodule CodeChallenge.Domain.Membership.Impl do
  @moduledoc false
  require Logger
  require CodeChallenge.Domain.Membership.API
  @behaviour CodeChallenge.Domain.Membership.API

  alias CodeChallenge.Schema.User

  alias CodeChallenge.Repo

  @impl true
  def members!() do
    User
    |> Repo.all(preload: [:visits, :member_transactions, :pal_transactions])
  end

  @impl true
  def join(%{email: email} = profile) do
    new_email_address?(email)
    |> store_if_new(profile)
  end
  def join(%{"email" => email} = profile) do
    new_email_address?(email)
    |> store_if_new(profile)
  end

  @impl true
  def login!(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @impl true
  def credit(_pal, nil), do: {:error, "Cannot reward credits for non-existent visit"}
  def credit(nil, _visit), do: {:error, "Cannot reward credits to an unregistered pal (not found)"}
  def credit(%{id: nil} = pal, _visit), do: {:error, "Cannot reward credits to an unregistered pal #{inspect(pal)}"}
  def credit(%{email: email, credits: credits} = pal, %{minutes: to_credit} = visit) when is_integer(credits) and is_integer(to_credit) do
    case login!(email) do
      %User{} ->
        new_balance = calculate_credit_balance(visit, to_credit, credits)

        pal
        |> update_balance(new_balance)
      _ ->
        {:error, "Invalid pal email (not found), cannot credit #{inspect(visit)} to #{inspect(pal)}."}
    end
  end

  @impl true
  def debit(_member, nil), do: {:error, "Cannot deduct credits for non-existent visit"}
  def debit(nil, _visit), do: {:error, "Cannot deduct credits from an unregistered member (not found)"}
  def debit(%{id: nil} = member, _visit), do: {:error, "Cannot deduct credits from an unregistered member #{inspect(member)}"}
  def debit(%{credits: credits, email: email} = member, %{minutes: to_debit} = visit) when is_integer(credits) and is_integer(to_debit) do
    case login!(email) do
      %User{} ->
        new_balance = calculate_debit_balance(member, to_debit, credits)
        member
        |> update_balance(new_balance)
      _ ->
        {:error, "Invalid member email (not found), cannot debit #{inspect(visit)} from #{inspect(member)}."}
    end
  end

  # Privates

  defp calculate_credit_balance(visit, to_credit, credits) do
    percentage_fee = Application.get_env(:code_challenge, :percentage_fee, 15)
    deduction = div(to_credit * percentage_fee, 100)

    #TODO: We need to account for this loss or else we're sunk.  I don't think tossing this value is part of the business plan.  Another Domain?
    Logger.info("We are losing our piece of the action #{inspect(deduction)} on Visit #{inspect(visit)}!")
    throw_on_the_floor(deduction)

    _new_balance = credits + (to_credit - deduction)
  end

  defp calculate_debit_balance(member, to_debit, credits) do
    new_balance = credits - to_debit
    # Keep credit from going below 0
    if new_balance >= 0 do
      new_balance
    else
      #TODO: Cancel existing outstanding Visit Requests or...?  They need to be suspended somehow until the build up a balance again.
      Logger.info("Member #{inspect(member)} exceeded balance #{inspect(credits)} when debited #{inspect(to_debit)}, setting balance to zero")
      #TODO: We need to account for this loss or we're sunk.  Requirements time...
      throw_on_the_floor(to_debit - credits)
      0
    end
  end

  defp email_exists?(email) when is_binary(email) do
    case login!(email) do
      %User{} -> true
      _ -> false
    end
  end
  defp new_email_address?(email), do: !email_exists?(email)

  defp store_if_new(true, profile) do
    store_profile(profile)
  end
  defp store_if_new(false, _profile) do
    {:error, "An account with the specified email already already exists, please  to retrieve it."}
  end

  defp store_profile(profile) do
    %User{}
    |> User.changeset(profile |> prepare_profile())
    |> Repo.insert()
  end

  defp prepare_profile(%{credits: nil} = profile) do
    credits = Application.get_env(:code_challenge, :default_starting_credits, 90)
    profile
    |> Map.from_struct()
    |> Map.take(User.field_list())
    |> Map.replace!(:credits, credits)
  end
  defp prepare_profile(%{credits: credits} = profile) when is_integer(credits) do
    profile
    |> Map.from_struct()
    |> Map.take(User.field_list())
  end

  defp throw_on_the_floor(deduction), do: deduction

  defp update_balance(%User{} = member, new_balance) do
    member
    |> User.changeset(%{(member |> Map.from_struct()) | credits: new_balance})
    |> Repo.update()
  end

  # Why, oh why, isn't struct written to handle PIPES!?
  def better_struct(%{} = map, module) do
    struct(module, map)
  end
end
