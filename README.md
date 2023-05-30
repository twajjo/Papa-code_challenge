# CodeChallenge

Jeff Osborn's response to the Code challenge described in the PDF at the root of the project.

## Setup

  * Run `git clone https://github.com/twajjo/Papa-code_challenge.git` in a local location to examine the project.

### Database in Docker

For convenience purposes, a docker-compose database server image has been provided in this project.

  * Run `docker-compose up -d` to run the postgres database if you have docker and docker-compose installed on your system.  The user is `postgres` and the password is as shown in the docker-compose.yml and for security purposes is not the standard password.

If you do not have docker installed, you will need to install postgres.  If this is the case you will have to change the username and password in the Repo config to match that of this new database.

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

  Domains are the areas of the model layer (in MV,MVC,MC,etc. division of responsibilities) that do not contain the physical model or schema itself but manage the business logic surrounding the model objects.
  
  Domains are essentially services governing a particular problem space and have a specific contract (API) governed by @callbacks.  Domain implementations can be interdependent with one another (they are just modules after all without state, ordinarilly).  Each domain is meant to field the essential use case of "I (domain x) don't know how to create a model y, can someone else do this?  Each domain provides a catalogue of services through its @callbacks.

  Domains are governed by 3 (or more) nodules to support a flexible service business logic abstraction layer to provide the key benevits of a domain:

  * An API module for adherence and compatibility.
  * An Interface module that determines the proper runtime implementation and delegates to it.  Note that the Interface adheres to the API behaviour.
  * At least one implementation that can field and process the API request.  Note that all Implementation modules must adhere to the API behaviour.

  Domains require up-front boilerplate work that provide a number of benefits in testing and long run code development:

  * Swappable at runtime
  * Great for unit test mocking (Mox).
  * Great for getting a "happy path" implementation running quickly for prototyping (DevStub)
  * Great for A/B testing in production.
  * Domains can service different "head ends", such as web controllers, RESTful APIs, Absinthe resolvers for GraphQL, back end batch processing, etc.

  ### API Description

  The API uses three different domains to govern the business logic of the challenge, each one focuses on managing one of the 3 schema models, but interoperates with all models and sometimes with each other.

  * Membership domain, responsible for creating, authenticating, managing and listing users (members and pals) and updating the data in User schema models and the database.
  * Request domain, responsible for creating, managing and fetching visits.
  * Fulfillment domain, responsible for fulfilling visits and creating transactions.

  ### Documentation

  * Run `mix help docs` to generate the full ExDoc for the Code Challenge.

  #### Membership Domain and API Summary
  
  For the purposes of the following service descriptions, the terms user, member and pal can be used interchangeably, but are referred to by the different names to provide context.

  The Membership domain manages Users and has the following functions in its interface:

    * credit/2

    Credit the given pal with the specified visit.

    Returns:
      {:ok, pal} - if the pal is valid and the credit was successfully made.
      {:error, reason} - if the pal is not valid or the visit could not be credited.

    * debit/2

    Debit the given member with the specified visit.

      {:ok, pal} - if the member is valid and the credit was successfully made.
      {:error, reason} - if the member is not valid or the visit could not be credited.

    * join/1

    Add a new member with the provided profile.

      {:ok, member} - if the member is valid and added successfully.
      {:error, reason} - if the member profile is not valid.

    * login!/1

    Returns a User record if provided a valid, recognized email address.

    Returns
      an unadorned User row with the given email.
      nil if the email is unrecognized.

    * members!/0

    Fetch a list of all users in the system.

    Returns:
      list - an unadorned list

  #### Request Domain and API Summary

  The Request domain manages Visits and has the following functions in its interface:

    * available/1

    Fetch a list of Visits that are available for the given pal to fulfill.

    Returns:
      {:ok, list} - if the pal is valid.
      {:error, reason} - if the pal is not valid.

    * available!/0

    Fetch a list of Visits that are waiting to be fulfilled.

    Returns:
      list - an unadorned list

    * fulfilled/1

    Fetch a list of Visits that have been fulfilled by the specified pal.

    Returns:
      {:ok, list} - if the pal is valid.
      {:error, reason} - if the pal is not valid.

    * fulfilled!/0

    Fetch a list of Visits that have been fulfilled by all pals.

    Returns:
      list - an unadorned list

    * outstanding/1

    Fetch a list of Visits that have been requested by the specified member that are not yet fulfilled.

    Returns:
      {:ok, list} - if the member is valid.
      {:error, reason} - if the member is not valid.

    * make/2

    Make a Visit request for the given user with the specified visit details.

    Returns:
      {:ok, visit} - if the member is valid.  The visit schema model result is confirmation.
      {:error, reason} - if the member is not valid.

  #### Fulfillment Domain and API and Summary

  The Fulfillment domain manages Transactions and has the following functions in its interface:

    * fulfill/2

    Fulfill the provided visit by the given pal.

    Returns:
    {:ok, transaction} - confirmation of the successful fulfillment.
    {:error, reason} - the reason for failing to fulfill the visit by the pal.

    * fulfilled!/0

    Fetch a list of all fulfilled Transactions in the system.

    Returns:
      list - an unadorned list

    * fulfilled_by_pal!/1

    Fetch a list of Transactions that have been fulfilled by the given pal.

    Returns:
      list - an unadorned list

    * fulfilled_for_member!/1

    Fetch a list of Transactions that have been fulfilled on behalf of the given member. 

    Returns:
      list - an unadorned list

  ### Test Drive

  * Run `iex -S mix` to start iex and try the system out.

  Let's create an initial user or two to try things out (the module path names for the domain interfaces have been address through aliases in `.iex.exs`):
  
  - `iex> {:ok, user1} = Membership.join(%User{first_name: "Erste", last_name: "Laste", email: "throckmorton.jones@rodney.com")`
  - `iex> {:ok, user2} = Membership.join(%User{first_name: "Fritz", last_name: "Latz", email: "an.email@valid.com")`

  We can repeat these steps as many times for as many new users as we wish.  Once there are a few users in the system, we can list them with:
  - `iex> Membership.members!()`

## Design Decisions and Assumptions

### Assumptions and issues

  * Initial seed Credits--I decided to provide the user with an initial (configurable) balance of seed credits, largely because there was no way to keep the "economy" of the system from bootstrapping without minutes to spend existing in the system already.
  * Over-debiting (not enough credits)-- How to deal with insufficient balances to fulfill a visit?
    - Currently, the balance is set to 0 if the member does not have enough on balance to "pay" the pal, but the pal is still awarded the full minutes for the visit minus fees.  This introduces "unaccounted" minutes into the system (potentially upsetting the economy).
    - User suspension, future visits can be prevented already, but what about unfulfilled visits by the delinquent member-- how should they be handled?
    - Preventing visits until a positive balance is acquired is a possibility.
  * What about the handling fee?  Right now, it is "thrown on the floor"-- ignored is should be accounted for somehow with, say, accounting.
  * How far in the future should new visits have to be? 
    - Currently, validation requires that visits be at least a day in the future, but that may not be enough and should probably be configurable.
  * Domains and Business Logic (substitutable at runtime)
  * Early release of DevStubs for integration testing by consumers of the API.
