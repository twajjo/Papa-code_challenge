defmodule CodeChallenge.Domain.Request do
  @moduledoc "Interface delegator for Request business logic."
  require CodeChallenge.Domain.Request.API
  @behaviour CodeChallenge.Domain.Request.API
  use CodeChallenge.Domain.DomainHook

  @impl true
  def fulfilled(member), do: runtime_module().fulfilled(member)

  @impl true
  def fulfilled!(), do: runtime_module().fulfilled!()

  @impl true
  def available(pal), do: runtime_module().available(pal)

  @impl true
  def available!(), do: runtime_module().available()

  @impl true
  def outstanding(member), do: runtime_module().outstanding(member)

  @impl true
  def make(member, request), do: runtime_module().make(member, request)
end
