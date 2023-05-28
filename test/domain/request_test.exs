defmodule CodeChallenge.Domain.Request.Test do
  @moduledoc false
  use ExUnit.Case, async: false

  import Mox
  import CodeChallenge.Test.Support.Factory
  import CodeChallenge.Test.Support.FactoryHelpers

  alias CodeChallenge.Repo
  alias CodeChallenge.Schema.{Transaction, User, Visit}
  alias CodeChallenge.Domain.Membership.Mock, as: Membership

  @request_domain CodeChallenge.Domain.Request.Impl

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "fulfilled/1" do
    test "cannot provide fulfilled visit list for unregistered pal" do
      assert {:error, message} = @request_domain.fulfilled(%User{id: nil})
      assert message =~ "unregistered"
    end
    test "cannot provide fulfilled visit list for invalid or nonexistent pal" do
      member = insert(:user)
      expect(Membership, :login!, 1, fn _ -> nil end)
      assert {:error, message} = @request_domain.fulfilled(member)
      assert message =~ "email"
    end
    test "provides a list of visits fulfilled by the valid pal" do
      members = gen_users(20)
      visits = gen_visits(members, 0..4, 15)
      workaholic = insert(:user)
      fulfill([], visits, workaholic, 10)
      expect(Membership, :login!, 1, fn _ -> workaholic end)
      assert list = @request_domain.fulfilled(workaholic)
    end
  end

  describe "fulfilled!/0" do
    test "returns a list of all completed visits in the system" do
      members = gen_users(20)
      pal_groups = members |> Enum.split(10) |> Tuple.to_list()
      visits = gen_visits(members, 0..4, 15)
      transacted_visits = pal_groups
        |> Enum.reduce([], fn pals, exclusions -> exclusions ++ fulfill(exclusions, visits, pals |> Enum.random(), 10) end)
        |> Enum.map(fn %Transaction{visit_id: visit_id} -> visit_id end)
      visits = @request_domain.fulfilled!()
      assert (visits |> Enum.count()) == (transacted_visits |> Enum.count())
      assert visits |> Enum.all?(fn %Visit{id: visit_id} -> visit_id in transacted_visits end)
    end
  end

  describe "available/1" do
    test "cannot provide available visit list for unregistered pal" do
      assert {:error, message} = @request_domain.available(%User{id: nil})
      assert message =~ "unregistered"
    end
    test "cannot provide available visit list for invalid or nonexistent pal" do
      pal = insert(:user)
      expect(Membership, :login!, 1, fn _ -> nil end)
      assert {:error, message} = @request_domain.available(pal)
      assert message =~ "email"
    end
    test "provides a list of visits available for the valid pal to fulfill" do

    end

  end

  describe "available!/0" do
    test "returns a list of all pending visits in the system" do
      members = gen_users(20)
      pal_groups = members |> Enum.split(10) |> Tuple.to_list()
      visits = gen_visits(members, 0..4, 15)
      transacted_visits = pal_groups
        |> Enum.reduce([], fn pals, exclusions -> exclusions ++ fulfill(exclusions, visits, pals |> Enum.random(), 10) end)
        |> Enum.map(fn %Transaction{visit_id: visit_id} -> visit_id end)
      available_visits = @request_domain.available!()
      assert (available_visits |> Enum.count()) == (visits |> Enum.count()) - (transacted_visits |> Enum.count())
      assert available_visits |> Enum.any?(fn %Visit{id: visit_id} -> visit_id in transacted_visits end) == false
    end
  end

  describe "outstanding/1" do
    test "cannot provide outstanding visit list for unregistered member" do
      assert {:error, message} = @request_domain.outstanding(%User{id: nil})
      assert message =~ "unregistered"
    end
    test "cannot provide outstanding visit list for invalid or nonexistent member" do
      member = insert(:user)
      expect(Membership, :login!, 1, fn _ -> nil end)
      assert {:error, message} = @request_domain.outstanding(member)
      assert message =~ "email"
    end
    test "provides a list of visits requested by the valid member that are still outstanding" do

    end
  end

  describe "make/2" do
    test "cannot make a visit request for an unregistered member" do

    end
    test "cannot make a visit request for an invalid or nonexistent member" do

    end
    test "a member cannot request a visit whose minute length is greater than their current balance" do

    end
    test "rejects visits whose date is in the past" do

    end
    test "rejects visits whose length in minutes is less than 1" do

    end
  end
end
