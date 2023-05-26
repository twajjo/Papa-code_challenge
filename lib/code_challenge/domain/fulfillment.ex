defmodule CodeChallenge.Domain.Fulfillment do
  @moduledoc "Interface delegator for Fulfillment business logic."
  require CodeChallenge.Domain.Fulfillment.API
  @behaviour CodeChallenge.Domain.Fulfillment.API
  use CodeChallenge.Domain.DomainHook

  @impl true
  def fulfill(pal, requested), do: runtime_module().fulfill(pal, requested)

  @impl true
  def fulfilled!(), do: runtime_module().fulfilled!()

  @impl true
  def fulfilled_by_pal!(pal), do: runtime_module().fulfilled_by_pal!(pal)

  @impl true
  def fulfilled_for_member!(member), do: runtime_module().fulfilled_for_member!(member)
end
