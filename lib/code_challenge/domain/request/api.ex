defmodule CodeChallenge.Domain.Request.API do
  @moduledoc """
  Handles implementation details for listing and managing visit requests.
  """
  alias CodeChallenge.Schema.{User, Visit}

  @doc """
  """
  @callback fulfilled(member :: %User{}) :: {:ok, list()} | {:error, %Ecto.Changeset{} | String.t()}

  @doc """
  List all fulfilled visits.

  Parameters

    none

  Returns

    The list of completed visits.
  """
  @callback fulfilled!() :: list()

  @doc """
  Get a list of open requests, excluding the those made by the specified user.  Used to get a list of visits that
  a pal has available to them

  Parameters

    pal - the user to excluded from the list of available request4s (those made by the pal themselves)

  Returns

    {:ok, list} - where list is the set of visit requests available to the pal.
    {:error, reason} - where reason explains why retrieving the list failed (likely user does not exist)
  """
  @callback available(pal :: %User{}) :: {:ok, list()} | {:error, %Ecto.Changeset{} | String.t()}

  @doc """
  Returns the list of currently available visit requests or an empty list of none are available.

  Parameters

    none

  Returns

    list of open visit requests or empty list.
  """
  @callback available!() :: list()

  @doc """
  Returns the list of currently open visit requests made by the given user.

  Parameters

    member - the user whose open visit list is to be returned.

  Returns

    {:ok, list} - where list is the set of open visit requests made by the member.  This value will be empty if the user has
      no open requests
    {:error, reason} - where reason explains why retrieving the list failed (likely member does not exist)
  """
  @callback outstanding(member :: %User{}) :: {:ok, list()} | {:error, %Ecto.Changeset{} | String.t()}

  @doc """
  Create a visit request.

  Parameters
    member - the member making the visit request
    request -
      date, minutes, tasks - as separate arguments
      map - containing necessary keys for creating Visit changeset.
      Visit - containing necessary keys for creating Visit changeset.

  Returns
    {:ok, visit} - where visit is the successfully stored visit row as confirmation.
    {:error, reason} - where reason describes the reason for the failure to create the visit.
  """
  @callback make(member :: %User{}, request :: map() | %Visit{}) :: {:ok, %Visit{}} | {:error, %Ecto.Changeset{} | String.t()}
end
