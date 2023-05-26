# List all modules that can be mocked in a test.  All modules MUST have ".API" module defined.
# .Mock modules will be created for each module listed below but must also be listed in config/test.exs

_modules_to_mock =
  [
    CodeChallenge.Domain.Fulfillment,
    CodeChallenge.Domain.Membership,
    CodeChallenge.Domain.Request
  ]
  |> Enum.each(fn
    # If the API implemented cannot be derived from the implementation name.
    {module, api} ->
      api
      |> List.wrap()
      |> Enum.each(fn a -> Code.ensure_compiled(a) end)

      Code.ensure_compiled(module)

      module
      |> Module.concat(Mock)
      |> Mox.defmock(for: api)

    module ->
      api = Module.concat(module, API)

      Code.ensure_compiled(api)
      Code.ensure_compiled(module)

      module
      |> Module.concat(Mock)
      |> Mox.defmock(for: api)
  end)
