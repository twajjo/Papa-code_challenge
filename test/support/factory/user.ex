defmodule CodeChallenge.Test.Support.Factory.User do
  defmacro __using__(_opts) do
    quote do
      alias CodeChallenge.Schema.User

      def user_factory do
        %User{
          id: generate_id(),
          first_name: Faker.Lorem.word() |> String.slice(0..20),
          last_name: Faker.Lorem.word() |> String.slice(0..20),
          email: "#{Faker.Lorem.word() |> String.slice(0..20)}.#{Faker.Lorem.word() |> String.slice(0..20)}@#{Faker.Lorem.word() |> String.slice(0..20)}.com",
          credits: 90
        }
      end
    end
  end
end
