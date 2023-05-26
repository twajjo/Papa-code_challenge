defmodule CodeChallenge.Test.Support.Utils do
  def generate_id do
    :rand.uniform(1_000_000_000)
  end

  def generate_uuid do
    Ecto.UUID.generate()
  end
end
