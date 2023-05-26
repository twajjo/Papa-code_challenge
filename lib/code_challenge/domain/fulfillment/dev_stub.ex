defmodule CodeChallenge.Domain.Fulfillment.DevStub do
  @moduledoc false
  require CodeChallenge.Domain.Fulfillment.API
  @behaviour CodeChallenge.Domain.Fulfillment.API

  alias CodeChallenge.Schema.{Transaction, User, Visit}

  @impl true
  def fulfill(%User{id: pal_id}, %Visit{id: visit_id, member_id: member_id}) do
    {:ok, %Transaction{member_id: member_id, pal_id: pal_id, visit_id: visit_id}}
  end
  def fulfill(%User{id: pal_id}, %{"id" => visit_id, "member_id" => member_id}) do
    {:ok, %Transaction{member_id: member_id, pal_id: pal_id, visit_id: visit_id}}
  end

  @impl true
  def fulfilled!(), do: []

  @impl true
  def fulfilled_by_pal!(_pal), do: []

  @impl true
  def fulfilled_for_member!(_member), do: []
end
