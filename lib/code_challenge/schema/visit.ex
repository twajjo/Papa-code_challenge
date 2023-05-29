
defmodule CodeChallenge.Schema.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  alias CodeChallenge.Schema.{Transaction, User}

  @primary_key {:id, :id, autogenerate: true}
  schema "visit" do
    field(:date, :utc_datetime)
    field(:minutes, :integer)
    field(:tasks, :string)
    belongs_to(:member, User, foreign_key: :member_id)
    has_one(:transaction, Transaction)

    timestamps([type: :utc_datetime_usec])
  end

  @required_fields ~w(
    member_id
    date
    minutes
    )a
  @optional_fields ~w(
    tasks
    )a
  @all_fields ~w()a ++ @required_fields ++ @optional_fields

  @spec changeset(%__MODULE__{} | %Ecto.Changeset{}, map) :: %Ecto.Changeset{}
  def changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    |> validate_number(:minutes, greater_than: 0)
    |> validate_change(:date, fn :date, %DateTime{} = date ->
      # TODO: make future date minimum (now 1 day) configurable
      if DateTime.compare(date, (DateTime.utc_now() |> Timex.add(Timex.Duration.from_days(1)) |> DateTime.truncate(:second))) == :gt do
        []
      else
        [date: "must be tomorrow or later"]
      end
    end)
  end

  defdelegate update_changeset(mod_struct, map), to: __MODULE__, as: :changeset

  @spec new_changeset :: %Ecto.Changeset{}
  def new_changeset do
    change(%__MODULE__{})
  end
end
