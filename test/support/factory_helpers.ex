defmodule CodeChallenge.Test.Support.FactoryHelpers do
  @moduledoc false
  alias CodeChallenge.Schema.{Transaction, User, Visit}

  import CodeChallenge.Test.Support.Factory

  def fulfill(_exclusions, _visits, %User{}, 0), do: []
  def fulfill(exclusions, visits, %User{id: pal_id} = pal, how_many) do
    %Visit{id: visit_id, member_id: member_id} = visit = visits |> Enum.random()
    if exclusions
      |> Enum.any?(fn
        %Transaction{visit_id: ^visit_id} -> true
        _ -> false
      end)
    do
      [] ++
      fulfill(exclusions, visits |> List.delete(visit), pal, how_many)
    else
      [insert(:transaction, visit_id: visit_id, pal_id: pal_id)] ++
        fulfill(exclusions, visits |> List.delete(visit), pal, how_many - 1)
    end
  end

  def fulfillable([], %User{}), do: nil
  def fulfillable(visits, %User{id: pal_id} = pal) when is_list(visits) do
    case visits |> Enum.random() do
      %Visit{member_id: ^pal_id} = nope -> visits |> List.delete(nope) |> fulfillable(pal)
      %Visit{} = can_do -> can_do
    end
  end

  def gen_users(count) do
    1..count
    |> Enum.map(fn _ -> insert(:user) end)
  end

  def gen_visits([], _range, _minutes), do: []
  def gen_visits([%User{id: member_id} | members], range, minutes) do
    count = range |> Enum.random()
    visits = 1..count
      |> Enum.map(fn week -> insert(:visit,
        member_id: member_id,
        date: DateTime.utc_now() |> Timex.add(Timex.Duration.from_weeks(week)),
        minutes: minutes,
        tasks: "Stuff"
        )
      end)
    visits ++ gen_visits(members, range, minutes)
  end
end
