defmodule CodeChallenge.Domain.DomainHook do
  defmodule API do
    @moduledoc """
    Allows interface modules to fetch the runtime implementation to use for the Interface module.

    Default: <Interface (use) module>.Impl
    """

    @doc """
    Fetch the runtime module.

    Parameters

      none

    Returns

      module - an implementation of Module to delegate interface functions to (Impl, DevStub, Mock).
    """
    @callback runtime_module() :: module()
  end
  defmacro __using__(_opts) do

    env_key = __MODULE__
      |> Module.split()
      |> Enum.join()
      |> Macro.underscore()
    default = __MODULE__
      |> Module.split()
      |> List.insert_at(-1, "Impl")
      |> Module.concat()

    quote do
      @behaviour CodeChallenge.Domain.DomainHook.API

      @impl true
      def runtime_module() do
        Application.get_env(:code_challenge, unquote(env_key), unquote(default))
      end
      defoverridable runtime_module: 0
    end
  end
end
