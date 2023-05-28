defmodule CodeChallenge.Test.Support.Factory do
  use ExMachina.Ecto, repo: CodeChallenge.Repo
  import CodeChallenge.Test.Support.Utils

  use CodeChallenge.Test.Support.Factory.Transaction
  use CodeChallenge.Test.Support.Factory.User
  use CodeChallenge.Test.Support.Factory.Visit
end
