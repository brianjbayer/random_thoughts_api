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

## API Endpoints
This API contains the following endpoints...

* **Index** all random thoughts: `get /random_thoughts?page={num}`
  (e.g. http://localhost:3000/random_thoughts?page=2)

* **Show** random thought {id}: `get /random_thoughts/{id}`
  (e.g. http://localhost:3000/random_thoughts/1)

* **Create** random thought: `post /random_thoughts/`
  with Request Body...
  ```json
  {
    "thought": "string",
    "name": "string"
  }
  ```

* **Update** random thought {id}: `patch /random_thoughts/{id}`
  with Request Body...
  ```json
  {
    "thought": "string",
    "name": "string"
  }
  ```

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
   ./script/dockercomposerun
   ```

2. To exit the containerized development environment, run the
   following command ...
   ```
   exit
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

## Operating

### Database
This project uses a Rails-supported PostgreSQL database with
the same configuration in all environments.

Use the `DATABASE_URL`environment variable set to a standard
database connection string to specify the database.

It is recommended to use the official
[PostgreSQL Docker image](https://hub.docker.com/_/postgres)
without a persistent volume (data) for the `development`
and `test` environments.

#### Seed Data

There is one sample record which can be added repeatedly.

Run the following command to add a seed record...
```
bundle exec bin/rails db:seed
```

### Testing
If you are using the same database for `development` and `test`,
run the following command first to set the database for the
`test` environment...
```
bundle exec bin/rails db:environment:set RAILS_ENV=test
```

Run the following command to run the tests...
```
./script/run tests
```

> :warning: If you are using the same database for `development`
> and `test`, these steps can destroy any data in your
> `development` database.

### Running the Application
Run the following command to run the Rails server...
```
./script/run server
```

or to run the server in detached mode...
```
./script/run server -d
```

---

## Swagger

### To Generate the Swagger File

Run the following command to generate the Swagger file for the
application...
```
./script/run swaggerize
```

### Swagger UI

By default the Swagger UI is located at http://localhost:3000/api-docs/


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
