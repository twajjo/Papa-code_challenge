defmodule CodeChallenge.Domain.Membership do
  @moduledoc false
  require CodeChallenge.Domain.Membership.API
  @behaviour CodeChallenge.Domain.Membership.API
  use CodeChallenge.Domain.DomainHook

  @impl true
  def members!(), do: runtime_module().members!()

  @impl true
  def join(profile), do: runtime_module().join(profile)

  @impl true
  def login!(email), do: runtime_module().login!(email)

  @impl true
  def credit(pal, visit), do: runtime_module().debit(pal, visit)

  @impl true
  def debit(member, visit), do: runtime_module().debit(member, visit)
end
