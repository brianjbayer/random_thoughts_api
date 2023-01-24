# WIP: random_thoughts_api

> **This is a Work In Progress**

A simple demonstration-only Rails API with OpenAPI (Swagger)
that implements a random thought in JSON format...
```json
{
  "thought": "A random thought",
  "name": "The Thinker's Name"
}
```

The `Dockerfile` for this project only supports the
Development Environment where the source code is volume
mounted into the container.

---

## Development
This project can be developed using the supplied basic, container-based
development environment which includes `vim`, `git`, `curl`, and `psql`.

The containerized development environment contains this application
along with an orchestrated PostgreSQL container.

The development environment application container volume mounts your
local source code to recognize and persist any changes.

By default the development environment application container executes
the `bash` shell providing a command line interface into the
application container.

### To Build the Development Environment Image

> **PREREQUISITE:** Docker must be installed and running

1. Run the following command to build the image...
   ```
   docker build --no-cache -t brianjbayer/random_thoughts_api-dev .
   ```

### To Run the Containerized Development Environment
The easiest way to run the containerized development environment is with
the docker-compose framework.

#### To Start the Containerized Development Environment

1. Run the following command to run the containerized development
   environment...
   ```
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml run --service-ports app
   ```

#### To Stop the Containerized Development Environment

1. Run the following command to stop the containerized development
   environment...
   ```
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml down
   ```

### Mappings to Host Machine
The containers in the containerized development environment have
their ports mapped to the host machine (i.e. `localhost`) for
visibility and access.

* A running Rails server in the application container is mapped to
  http://localhost:3000.

* The PostgreSQL container is mapped to `localhost:5432` and can
  be accessed on the host machine with the database connection string
  `postgresql://random_thoughts_api:banana@localhost:5432/random_thoughts_api`
  (e.g. `psql postgresql://random_thoughts_api:banana@localhost:5432/random_thoughts_api`)

---

## Specifications
### Versions

* Rails: 7.0.4
* Ruby: 3.2.0

### Support

* [PostgreSQL](https://www.postgresql.org/) - Database
* [RSpec](http://rspec.info/) - Test Framework
* [Factory Bot](https://github.com/thoughtbot/factory_bot) - Test Data Factory Framework
* [rswag](https://github.com/rswag/rswag) - Swagger/OpenAPI Tooling
