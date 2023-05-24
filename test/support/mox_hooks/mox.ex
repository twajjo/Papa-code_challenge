# List all modules that can be mocked in a test.  All modules MUST have ".API" module defined.
# .Mock modules will be created for each module listed below but must also be listed in config/test.exs
_modules_to_mock =
  []
  |> Enum.each(fn
    # If the API implemented cannot be derived from the implementation name.
    {module, api} ->
      Code.ensure_compiled(module)

      api
      |> List.wrap()
      |> Enum.each(fn a -> Code.ensure_compiled(a) end)

      module
      |> Module.concat(Mock)
      |> Mox.defmock(for: api)

    module ->
      Code.ensure_compiled(module)
      Code.ensure_compiled(Module.concat(module, API))

      module
      |> Module.concat(Mock)
      |> Mox.defmock(for: Module.concat(module, API))
  end)
