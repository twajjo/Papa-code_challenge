defmodule CodeChallenge.Test.Support.Factory.Transaction do
  defmacro __using__(_opts) do
    quote do
      alias CodeChallenge.Schema.Transaction

      def transaction_factory do
        %Transaction{
          id: generate_id()
        }
      end
    end
  end
end
