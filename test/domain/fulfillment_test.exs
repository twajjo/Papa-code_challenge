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
      members = gen_users(10)
      pal = Enum.random(members)
      visit = gen_visits(members, 0..4, 15) |> fulfillable(pal)
      expect(Membership, :login!, 1, fn _ -> nil end)
      assert {:error, message} = @fulfillment_domain.fulfill(pal, visit)
      assert message =~ "email"
    end
    test "only one fulfillment can be made per visit" do
      members = gen_users(10)
      pal = %User{id: pal_id} = Enum.random(members)
      visits = gen_visits(members, 1..4, 15)
      fulfilled = fulfill([], visits, pal, 10)
      expect(Membership, :login!, 1, fn _ -> pal end)
      %Transaction{visit_id: visit_id, member_id: member_id, pal_id: ^pal_id} = Enum.random(fulfilled)
      assert {:error, message} = @fulfillment_domain.fulfill(pal, %Visit{id: visit_id, member_id: member_id})
      assert (message |> inspect()) =~ "has already been taken"
    end
    test "the fulfillment transaction is completed successfully" do
      members = gen_users(10)
      pal = Enum.random(members)
      visit = gen_visits(members, 1..4, 15) |> Enum.random()

      expect(Membership, :login!, 1, fn _ -> pal end)
      expect(Membership, :credit, 1, fn _,_ -> nil end)
      expect(Membership, :debit, 1, fn _,_ -> nil end)
      assert {:ok, %Transaction{}} = @fulfillment_domain.fulfill(pal, visit)
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
      members = gen_users(10)
      visits = gen_visits(members, 1..4, 15)
      pal1 = %User{id: pal1_id} = Enum.random(members)
      pal2 = %User{id: pal2_id} = Enum.random(members |> List.delete(pal1))
      fulfill([], visits, pal1, 15)
      |> fulfill(visits, pal2, 12)
      fulfilled_pal1 = @fulfillment_domain.fulfilled_by_pal!(pal1)
      assert Enum.count(fulfilled_pal1) == 15
      assert Enum.all?(fulfilled_pal1, fn
        %Transaction{pal_id: ^pal1_id} -> true
        _ -> true
      end)
      fulfilled_pal2 = @fulfillment_domain.fulfilled_by_pal!(pal2)
      # There may have not been enough remaining visits for pal2 to fulfill hir commitment to 12
      assert Enum.count(fulfilled_pal2) <= 12
      assert Enum.all?(fulfilled_pal2, fn
        %Transaction{pal_id: ^pal2_id} -> true
        _ -> true
      end)
    end
  end

  describe "fulfilled_for_member!/1" do
    test "lists all transactions in the system fulfilled on behalf of the given member" do
      members = gen_users(10)
      visits = gen_visits(members, 1..4, 15)
      # Now fulfill ALL the visits
      fulfilled = members
        |> Enum.reduce([], fn pal, exclusions -> exclusions ++ fulfill(exclusions, visits, pal, 10) end)
      member = %User{id: member_id}= Enum.random(members)
      list = @fulfillment_domain.fulfilled_for_member!(member)
      member_fulfilled = fulfilled |> Enum.filter(fn
        %Transaction{member_id: ^member_id} -> true
        _ -> false
      end)
      assert Enum.count(list) == Enum.count(member_fulfilled)
      assert list |> Enum.all?(fn transaction -> transaction in member_fulfilled end)
    end
  end
end
