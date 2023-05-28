defmodule CodeChallenge.Domain.Membership.Test do
  @moduledoc false
  use ExUnit.Case, async: false

  import CodeChallenge.Test.Support.Factory
  import CodeChallenge.Test.Support.FactoryHelpers

  alias CodeChallenge.Repo

  alias CodeChallenge.Schema.{User, Visit}

  @membership_domain CodeChallenge.Domain.Membership.Impl

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "members!/0" do
    test "returns a list of all users in the system" do
      assert @membership_domain.members!() |> Enum.count() == 0
      gen_users(20)
      assert @membership_domain.members!() |> Enum.count() == 20
    end
  end

  describe "join/1" do
    test "does not allow joining with an existing email" do
      existing_user = gen_users(30)
      |> Enum.random()
      assert {:error, message} = @membership_domain.join(existing_user)
      assert message =~ "exists"
    end
    test "creates the user/pal/member with a unique email" do
      user = %User{first_name: "Winston", last_name: "Churchill", email: "brumpy@bullmastiff.com"}
      assert {:ok, %User{id: id, credits: credits}} = @membership_domain.join(user)
      assert not is_nil(id)
      assert credits == 90
    end
  end

  describe "login!/1" do
    test "returns the User with the specified email" do
      existing_user = %User{email: email} = gen_users(30) |> Enum.random()
      assert @membership_domain.login!(email) == existing_user
    end
    test "returns nil if the email is unrecognized" do
      assert @membership_domain.login!("bogus@tothemax.com") == nil
    end
  end

  describe "credit/2" do
    test "cannot reward pal with credits if they are unregistered" do
      pals = gen_users(10)
      visit = gen_visits(pals, 0..4, 15) |> Enum.random()
      assert {:error, message} = @membership_domain.credit(%User{id: nil}, visit)
      assert message =~ "unregistered"
    end
    test "pal to credit must be valid and exist" do
      pals = gen_users(10)
      visit = gen_visits(pals, 0..4, 15) |> Enum.random()
      assert {:error, message} = @membership_domain.credit(%User{id: 9, email: "narf@pinky.com", credits: 90}, visit)
      assert message =~ "email"
    end
    test "credit successfully added to balance" do
      pals = gen_users(10)
      %User{credits: starting} = pal = pals |> Enum.random()
      visit = gen_visits(pals, 0..4, 15) |> fulfillable(pal)
      assert {:ok, %User{credits: ending}} = @membership_domain.credit(pal, visit)
      assert ending > starting
    end
  end

  describe "debit/2" do
    test "cannot debit member with credits if they are unregistered" do
      members = gen_users(10)
      visit = gen_visits(members, 0..4, 15) |> Enum.random()
      assert {:error, message} = @membership_domain.debit(%User{id: nil}, visit)
      assert message =~ "unregistered"
    end
    test "member to debit must be valid and exist" do
      members = gen_users(10)
      visit = gen_visits(members, 0..4, 15) |> Enum.random()
      assert {:error, message} = @membership_domain.debit(%User{id: 9, email: "narf@pinky.com", credits: 90}, visit)
      assert message =~ "email"
    end
    test "debit to member will not drop balance below zero (insufficient balance)" do
      pal = %User{credits: 5} = insert(:user, credits: 5)
      members = gen_users(10)
      visit = gen_visits(members, 0..4, 15) |> Enum.random()
      assert {:ok, %User{credits: 0}} = @membership_domain.debit(pal, visit)
    end
    test "debit successfully subtracted from adequate balance" do
      pal = %User{credits: starting} = insert(:user)
      members = gen_users(10)
      visit = gen_visits(members, 0..4, 15) |> Enum.random()
      assert {:ok, %User{credits: ending}} = @membership_domain.debit(pal, visit)
      assert ending < starting
      assert ending > 0
    end
  end
end
