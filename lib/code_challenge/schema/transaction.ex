defmodule CodeChallenge.Schema.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias CodeChallenge.Schema.{User, Visit}

  @primary_key {:id, :id, autogenerate: true}
  schema "transaction" do
    belongs_to(:member, User, foreign_key: :member_id)
    belongs_to(:pal, User, foreign_key: :pal_id)
    belongs_to(:visit, Visit, foreign_key: :visit_id)
    timestamps([type: :utc_datetime_usec])
  end

  @required_fields ~w(
    member_id
    pal_id
    visit_id
    )a
  @optional_fields ~w(
    )a
  @all_fields ~w()a ++ @required_fields ++ @optional_fields

  @spec changeset(%__MODULE__{} | %Ecto.Changeset{}, map) :: %Ecto.Changeset{}
  def changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
  end

  defdelegate update_changeset(mod_struct, map), to: __MODULE__, as: :changeset

  @spec new_changeset :: %Ecto.Changeset{}
  def new_changeset do
    change(%__MODULE__{})
  end
end
