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

## Usage and Examples

  ### Domain Concept

  * Swappable at runtime
  * Great for unit test mocking (Mock)
  * Great for getting a "happy path" implementation running quickly for prototyping (DevStub)
  * Great for A/B testing in production.

  ### API Description

  The API uses three different domains to govern the business logic of the challenge, each one focuses on managing one of the 3 schema models, but interoperates with all models and sometimes with each other.

  * Membership domain, responsible for creating, authenticating, managing and listing users (members and pals) and updating the data in User schema models and the database.
  * Request domain, responsible for creating, managing and fetching visits.
  * Fulfillment domain, responsible

  #### Membership Domain and API

  #### Request Domain and API

  #### Fulfillment Domain and API

  ### Test Drive

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
