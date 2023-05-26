defmodule CodeChallenge.Domain.Request.DevStub do
  @moduledoc false
  require CodeChallenge.Domain.Request.API
  @behaviour CodeChallenge.Domain.Request.API

  alias CodeChallenge.Schema.{User, Visit}

  @impl true
  def fulfilled(_member), do: {:ok, []}

  @impl true
  def fulfilled!(), do: []

  @impl true
  def available(_pal), do: {:ok, []}

  @impl true
  def available!(), do: []

  @impl true
  def outstanding(_member), do: {:ok, []}

  @impl true
  def make(%User{id: member_id}, %{date: date, minutes: minutes, tasks: tasks}) do
    {:ok, %Visit{member_id: member_id, date: date, minutes: minutes, tasks: tasks}}
  end
  def make(%User{id: member_id}, %{"date" => date, "minutes" => minutes, "tasks" => tasks}) do
    {:ok, %Visit{member_id: member_id, date: date, minutes: minutes, tasks: tasks}}
  end
end
