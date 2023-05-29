defmodule CodeChallenge.Domain.Fulfillment.API do
  @moduledoc """
  Handles implementation details for listing and managing the visit fulfillment process.
  """
  alias CodeChallenge.Schema.{Transaction, User, Visit}

  @doc """
  Satisfy a visit request by a pal.

  Parameters

    requested - the visit requested by a member.
    pal - the user fulfilling the visit request.

  Returns

    {:ok, transaction} - where transaction is the confirmation of the fulfillment.
    {:error, reason} - where reason explains the failure.
  """
  @callback fulfill(pal :: %User{}, requested :: map() | %Visit{}) :: {:ok, %Transaction{}} | {:error, %Ecto.Changeset{} | String.t()}

  @doc """
  Lists all fulfilled Transactions.

  Parameters

    none

  Returns

    A list of all Transactions in the system.
  """
  @callback fulfilled!() :: list()

  @doc """
  Lists all Transactions fulfilled by a given pal.

  Parameters

    pal - the pal %User record to retrieve the list for.

  Returns

    A list of all Transactions fulfilled by the given pall.
  """
  @callback fulfilled_by_pal!(pal :: %User{}) :: list()

  @doc """
  Lists all Transactions fulfilled on behalf of a given member.

  Parameters

    member - the member %User record to retrieve the list for.

  Returns

    A list of all Transactions fulfilled on behalf of the specified member.
  """
  @callback fulfilled_for_member!(member :: %User{}) :: list()
end
