defmodule CodeChallenge.Domain.Membership.DevStub do
  @moduledoc false
  require CodeChallenge.Domain.Membership.API
  @behaviour CodeChallenge.Domain.Membership.API

  alias CodeChallenge.Schema.User

  @impl true
  def members!(), do: {:ok, []}

  @impl true
  def join(%{first_name: first_name, last_name: last_name, email: email, credits: credits}) do
    {:ok,  %User{first_name: first_name, last_name: last_name, email: email, credits: credits}}
  end
  def join(%{"first_name" => first_name, "last_name" => last_name, "email" => email, "credits" => credits}) do
    {:ok,  %User{first_name: first_name, last_name: last_name, email: email, credits: credits}}
  end

  @impl true
  def login!(email) when is_binary(email) do
    %User{first_name: "Maydup", last_name: "Name", email: email, credits: 90}
  end

  @impl true
  def credit(pal, _visit), do: {:ok, pal}

  @impl true
  def debit(member, _visit), do: {:ok, member}
end
