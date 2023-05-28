# CodeChallenge

## Setup

### Database in Docker

### Ecto DDL Steps

  * Run `mix deps.get` to get the project dependencies.
  * Run `mix ecto.create` to create the dev database to use to try out the API.
  * Run `mix ecto.migrate` to apply the data model to the dev database for the usage examples below.
  * Run `MIX_ENV=test mix ecto.create` to create the test database to run unit tests.
  * Run `MIX_ENV=test mix ecto.migrate` to apply the data model to the test database to make running unit tests possible.

## Testing

  * Run `mix test` to run the unit tests.

  There will be a number of warnings issued as the unit tests are run to describe missing requirements when dealing with Transaction 
  fulfillment and can be ignored, although their meaning is described below under Design Decisions and Assumptions

## Usage and Examples

  # API Description

  run `iex -S mix` to get the project dependencies.

## Design Decisions and Assumptions

Assumptions

  * Initial seed Credits
  * Over-debiting (not enough credits)
    - User suspension
    - Preventing visits until a positive balance is acquired.
  * What about the handling fee?

  * Domains and Business Logic (substitutable at runtime)
  * Early release of DevStubs for integration testing by consumers of the API.

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
