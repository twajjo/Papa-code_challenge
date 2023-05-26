defmodule CodeChallenge.Test.Support.Factory.Visit do
  defmacro __using__(_opts) do
    quote do
      alias CodeChallenge.Schema.Visit

      def visit_factory do
        %Visit{
          id: generate_id(),
          minutes: 30,
          tasks: Faker.Lorem.word(),
          date: Faker.DateTime.forward(30)
        }
      end
    end
  end
end
