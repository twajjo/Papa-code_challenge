defmodule CodeChallenge.Domain.Membership.API do
  @moduledoc """
  Handles implementation details for listing and managing memberships.
  """
  alias CodeChallenge.Schema.{User, Visit}

  @doc """
  Lists all members (and pals) in a user list.

  Parameters

    none

  Returns

    A list of all members in the system.
  """
  @callback members!() :: list()

  @doc """
  Allows a person to register as a user (member or pal)

  Parameters

    profile -
      map/User struct - a set of necessary values to create an insert changeset for a User

  Returns

    {:ok, user} - where user is the newly created user row for the member as confirmation.
    {:error, reason} - where reason explains failures that occur (likely with field value validation)
  """
  @callback join(profile :: map() | %User{}) :: {:ok, %User{}} | {:error, %Ecto.Changeset{} | String.t()}

  @doc """
  Retrieves the member/pal user for the specified email address.

  Parameters

    email - the address of the user row to retrieve.

  Returns

    {:ok, user} - where user is the matching user for the email address.
    {:error, reason} - where reason explains any failures (likely no such user)
  """
  @callback login!(email :: String.t()) :: %User{} | nil

  @doc """
  Add the specified credits to the pal's account (minus handling fees)

  Parameters
    pal - the pal to credit with the minutes specified (minus any fees)
    minutes - the number of minutes in the visit the pal fulfilled.

  Returns
    {:ok, user} - where user is the updated pal record
    {:error, reason} - where reason explains the error (likely pal row not found for update)
  """
  @callback credit(pal :: %User{}, visit :: map | %Visit{}) :: {:ok, %User{}} | {:error, %Ecto.Changeset{} | String.t()}

  @doc """
  Subtract the specified minutes from the member's account.

  Parameters
    member - the member whose account is to be debited the minutes specified.
    minutes - the number of minutes in the visit the member was attended.

  Returns
    {:ok, user} - where user is the updated member record
    {:error, reason} - where reason explains the error (likely member row not found for update)
  """
  @callback debit(member :: %User{}, visit :: map | %Visit{}) :: {:ok, %User{}} | {:error, %Ecto.Changeset{} | String.t()}
end
