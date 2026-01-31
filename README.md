# random_thoughts_api

## What It Is

This is an example of a public
[Ruby on Rails](https://rubyonrails.org/)
[Web API](https://wikipedia.org/wiki/Web_API)
that contains and demonstrates...

* API versioning
* Self documentation of the API
* JWT-based authorization (JSON Web Token) with instant
  revocation without allow or deny lists
* OpenAPI ([Swagger](https://swagger.io/)) specification and
  tooling
* [Rack](https://wikipedia.org/wiki/Rack_(web_server_interface))-based
  health checks
* Container-based deployment artifacts (versus source code)
* Docker compose framework for operating, developing, and
  testing the application
* Continuous Integration (CI) using
  [GitHub Actions](https://github.com/features/actions)
* Secrets management
* Environment variable based configuration
* Code Style enforcement, linting, and static security
  analysis and dependency scanning

## What It Does

This API represents *Users* and their *RandomThoughts* which
are represented in JSON format...

```json
{
  "thought": "A random thought",
  "mood": "The mood of the thought and/or user",
  "name": "The user's display name"
}
```

> :eyes: For more information, see the
> [APPLICATION_DATA_MODEL.md](docs/APPLICATION_DATA_MODEL.md)

---

## API Versions

The current and latest version of this API is version `v1`.

## Endpoints

### API Endpoints

The latest version of this API contains...

* **Authentication** endpoints...
  * Login
  * Logout

* **User** endpoints...
  * Index
  * Show
  * Create
  * Update
  * Delete

* **RandomThoughts** endpoints...
  * Index
  * Show
  * Create
  * Update
  * Delete

> :eyes: For a summary of these endpoints, see
> [V1_API_ENDPOINTS.md](docs/V1_API_ENDPOINTS.md) or
> for a complete specification of the API, see the
> [Swagger File](https://github.com/brianjbayer/random_thoughts_api/blob/main/swagger/v1/swagger.yaml)
> for the latest version

### Self-Documenting Root Endpoint

The root endpoint (i.e. `get /`) returns the latest version of
the application's Swagger File (i.e. OpenAPI specification) in
JSON, thus making this application self-documenting.

### Health Check Endpoints

There are two health-check endpoints for determining the current
health status of the application:

* `/livez` - a *Liveness* endpoint that indicates that the
  application is running but not necessarily healthy
  (e.g. <http://localhost:3000/livez>)

* `/readyz` - a *Readiness* endpoint that indicates that the
  application is healthy and ready for requests
  (e.g. <http://localhost:3000/readyz>)

## Running the Application
>
> :apple: The images built for this project are multi-platform
> images that support both `linux/amd64` (e.g. x86) and
> `linux/arm64` (i.e. Apple Silicon)

The easiest way to run the application is with the docker compose
framework using the `dockercomposerun` script.

This will pull the latest docker image of this project and run
the server along with an orchestrated PostgreSQL container.

### Prerequisites

In order to run this application...

1. You must have Docker installed and running on your host
   machine

2. You must set the required Rails environment variable
   `SECRET_KEY_BASE`

3. You must set the required environment variable `APP_JWT_SECRET`

> :eyes: For more information, see
> [PREREQUISITES.md](docs/PREREQUISITES.md)

### Running the Application Server

To run the server using the docker compose framework, run
the following command

```
./script/dockercomposerun
```

### Mappings to Host Machine

The containers in the docker compose framework have their
ports mapped to the host machine (i.e. `localhost`) for
visibility and access.

* The running Rails server in the application container is mapped to
  <http://localhost:3000> by default

* The PostgreSQL container is mapped to `localhost:5432` and can
  be accessed on the host machine with the database connection string
  `postgresql://random_thoughts_api:${POSTGRES_PASSWORD:-banana}@db:5432/random_thoughts_api`
  (e.g. `psql postgresql://random_thoughts_api:banana@localhost:5432/random_thoughts_api`)

### Swagger UI

Once the application is running, the Swagger UI is located at
<http://localhost:3000/api-docs/>

## Development

This project can be developed using the supplied
container-based development environment which includes
`vim`, `git`, `curl`, and `psql`.

> :eyes: For more information, see [DEVELOPMENT.md](docs/DEVELOPMENT.md)

---

## Specifications

### Versions

* Rails: 7.2.2
* Ruby: 4.0.1

### Support

* [PostgreSQL](https://www.postgresql.org/) - Database
* [rswag](https://github.com/rswag/rswag) - Swagger/OpenAPI
  Tooling
* [JWT](https://github.com/jwt/ruby-jwt) - Authorization
* [Kaminari](https://github.com/kaminari/kaminari) - Pagination
* [RSpec](http://rspec.info/) - Test Framework
* [Factory Bot](https://github.com/thoughtbot/factory_bot) - Test
  Data Factory Framework
* [Faker](https://github.com/faker-ruby/faker) - Fuzzing Test Data
* [Shoulda Matchers](https://matchers.shoulda.io/) - Test Expectation
  Matchers
* [SimpleCov](https://github.com/simplecov-ruby/simplecov) - Test Coverage
  Reporting
* [brakeman](https://brakemanscanner.org/) - Static Security Analysis
* [bundler-audit](https://github.com/rubysec/bundler-audit) - Dependency
  Static Security
* [rubocop](https://github.com/rubocop/rubocop),
  [rubocop-rails](https://github.com/rubocop/rubocop-rails),
  [rubocop-rspec](https://github.com/rubocop/rubocop-rspec) - Code Style
  and Linting
* [actions-image-cicd](https://github.com/brianjbayer/actions-image-cicd) - Continuous
  Integration
