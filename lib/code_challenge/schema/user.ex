defmodule CodeChallenge.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias CodeChallenge.Schema.{Transaction, Visit}

  @primary_key {:id, :id, autogenerate: true}
  schema "user" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:credits, :integer)
    has_many(:visits, Visit, foreign_key: :member_id)
    has_many(:member_transactions, Transaction, foreign_key: :member_id)
    has_many(:pal_transactions, Transaction, foreign_key: :pal_id)
    timestamps([type: :utc_datetime_usec])
  end

  @required_fields ~w(
    first_name
    last_name
    email
    )a
  @optional_fields ~w(
    credits
    )a
  @all_fields ~w()a ++ @required_fields ++ @optional_fields

  def field_list(), do: @all_fields

  @spec changeset(%__MODULE__{} | %Ecto.Changeset{}, map) :: %Ecto.Changeset{}
  def changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    # TODO: validate email
  end

  defdelegate update_changeset(mod_struct, map), to: __MODULE__, as: :changeset

  @spec new_changeset :: %Ecto.Changeset{}
  def new_changeset do
    change(%__MODULE__{})
  end

end
