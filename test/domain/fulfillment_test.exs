defmodule CodeChallenge.Domain.Fulfillment.Test do
  @moduledoc false
  use ExUnit.Case, async: false

  import Mox
  import CodeChallenge.Test.Support.Factory
  import CodeChallenge.Test.Support.FactoryHelpers

  alias CodeChallenge.Repo
  alias CodeChallenge.Schema.{Transaction, User, Visit}
  alias CodeChallenge.Domain.Membership.Mock, as: Membership

  @fulfillment_domain CodeChallenge.Domain.Fulfillment.Impl

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "fulfill/2" do
    test "fulfilling pal must define a registered user" do
      assert {:error, message} = @fulfillment_domain.fulfill(%User{id: nil}, %Visit{})
      assert message =~ "unregistered"
    end
    test "a pal may not fulfill their own requests" do
      pal = %User{id: member_id} = insert(:user, credits: 90)
      visit = insert(:visit, member_id: member_id, date: DateTime.utc_now() |> Timex.add(Timex.Duration.from_days(3)), minutes: 15, tasks: "More stuff")
      assert {:error, message} = @fulfillment_domain.fulfill(pal, visit)
      assert message =~ "their own"
    end
    test "fulfilling pal must be valid and exist" do
      pals = gen_users(10)
      pal = Enum.random(pals)
      visit = gen_visits(pals, 0..4, 15) |> fulfillable(pal)
      expect(Membership, :login!, 1, fn _ -> nil end)
      assert {:error, message} = @fulfillment_domain.fulfill(pal, visit)
      assert message =~ "email"
    end
    test "only one fulfillment can be made per visit" do
    end
    test "the fulfillment transaction is completed successfully" do
    end
  end

  describe "fulfilled!/0" do
    test "lists all transactions in the system" do
      members = gen_users(20)
      pal_groups = members |> Enum.split(10) |> Tuple.to_list()
      visits = gen_visits(members, 0..4, 15)
      transacted_visits = pal_groups
        |> Enum.reduce([], fn pals, exclusions -> exclusions ++ fulfill(exclusions, visits, pals |> Enum.random(), 10) end)
        |> Enum.map(fn %Transaction{visit_id: visit_id} -> visit_id end)
      transactions = @fulfillment_domain.fulfilled!()
      assert (transactions |> Enum.count()) == (transacted_visits |> Enum.count())
      assert transactions |> Enum.all?(fn %Transaction{visit_id: visit_id} -> visit_id in transacted_visits end)
    end
  end

  describe "fulfilled_by_pal!/1" do
    test "lists all transactions in the system fulfilled by the given pal" do
    end
  end
  describe "fulfilled_for_member!/1" do
    test "lists all transactions in the system fulfilled on behalf of the given member" do
    end
  end
end
