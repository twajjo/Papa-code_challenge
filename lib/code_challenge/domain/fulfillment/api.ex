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
  @callback fulfilled!() :: list()
  @callback fulfilled_by_pal!(pal :: %User{}) :: list()
  @callback fulfilled_for_member!(member :: %User{}) :: list()
end
